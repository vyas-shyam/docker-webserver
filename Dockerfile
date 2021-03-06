FROM alpine:3.8
MAINTAINER Rakshit Menpara <rakshit@improwised.com>

ENV DOCKERIZE_VERSION v0.6.0
ENV DRAFTER_VERSION v3.2.7
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

################## INSTALLATION STARTS ##################

# Install OS Dependencies
RUN set -ex \
  && apk add --no-cache --virtual .build-deps \
    autoconf automake build-base python gmp-dev \
    curl \
    nodejs nodejs-npm \
    tar \
  && apk add --no-cache --virtual .run-deps \
    # PHP and extensions
    php7 php7-apcu php7-bcmath php7-dom php7-ctype php7-curl php7-exif php7-fileinfo \
    php7-fpm php7-gd php7-gmp php7-iconv php7-intl php7-json php7-mbstring php7-mcrypt \
    php7-mysqlnd php7-mysqli php7-opcache php7-openssl php7-pcntl php7-pdo php7-pdo_mysql \
    php7-phar php7-posix php7-session php7-simplexml php7-sockets php7-sqlite3 php7-tidy \
    php7-tokenizer php7-xml php7-xmlreader php7-xmlwriter php7-zip php7-zlib php7-redis php7-soap php7-dev \

    # Other dependencies
    mariadb-client sudo \
    # Miscellaneous packages
    bash ca-certificates dialog git libjpeg libpng-dev openssh-client supervisor vim wget \
    # Nginx
    nginx \
    # Create directories
  && mkdir -p /etc/nginx \
    && mkdir -p /run/nginx \
    && mkdir -p /etc/nginx/sites-available \
    && mkdir -p /etc/nginx/sites-enabled \
    && mkdir -p /var/log/supervisor \
    && rm -Rf /var/www/* \
    && rm -Rf /etc/nginx/nginx.conf \
  # Composer
  && wget https://composer.github.io/installer.sig -O - -q | tr -d '\n' > installer.sig \
    && php7 -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php7 -r "if (hash_file('SHA384', 'composer-setup.php') === file_get_contents('installer.sig')) { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php7 composer-setup.php --install-dir=/usr/bin --filename=composer \
    && php7 -r "unlink('composer-setup.php'); unlink('installer.sig');" \
  # Install drafter
  && cd /tmp \
    && git clone -b $DRAFTER_VERSION --recursive --single-branch --depth 1 https://github.com/apiaryio/drafter.git \
    && cd drafter \
    && ./configure \
    && make drafter \
    && make install \
    && drafter -v \
  # Install opencensus extension
  && cd /tmp \
    && git clone https://github.com/census-instrumentation/opencensus-php.git \
    && cd opencensus-php/ext \
    && phpize \
    && ./configure --enable-opencensus \
    && make \
    && make test \
    && make install \
    && cd && rm -rf /tmp/drafter && rm -rf /tmp/opencensus* \
  # Cleanup
  && apk del .build-deps

##################  INSTALLATION ENDS  ##################

##################  CONFIGURATION STARTS  ##################

ADD rootfs /

RUN ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf && \
    ln -s /etc/php7/php.ini /etc/php7/conf.d/php.ini && \
    chown -R nginx:nginx /var/www

RUN echo "extension = /usr/lib/php7/modules/opencensus.so;" >> /etc/php7/conf.d/php.ini 


##################  CONFIGURATION ENDS  ##################

EXPOSE 443 80

WORKDIR /var/www

ENV DRAFTER_PATH /usr/local/bin/drafter

ENTRYPOINT ["dockerize", \
    "-template", "/etc/php7/php.ini:/etc/php7/php.ini", \
    "-template", "/etc/php7/php-fpm.conf:/etc/php7/php-fpm.conf", \
    "-template", "/etc/php7/php-fpm.d:/etc/php7/php-fpm.d", \
    "-template", "/google-auth.json.tmpl:/google-auth.json", \
    "-stdout", "/var/www/storage/logs/laravel.log", \
    "-stdout", "/var/log/nginx/error.log", \
    "-stdout", "/var/log/php7/error.log", \
    "-poll"]

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]
