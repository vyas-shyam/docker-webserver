# Web Server
Nginx & PHP 7 web server.

# Laravel Application - Quick Run
Using the Laravel installer you can get up and running with a Laravel application inside Docker in minutes.
* Create a new Laravel application `$ laravel new testapp`
* Change to the applications directory `$ cd testapp`
* Start the container and attach the application. `$ docker run -d -p 4488:80 --name=testapp -v $PWD:/var/www webserver`
* Visit the Docker container URL like [http://0.0.0.0:4488](http://0.0.0.0:4488). Profit!

### Environment Variables
Here are some configurable environment values.
* `APP_ENV` - Application environment. Any of `production`, `staging`, `testing` to load specific configuration at runtime from `.env.<environment>`
* `WEBROOT` – Path to the web root. Default: `/var/www`
* `PRODUCTION` – Is this a production environment. Default: `0`
* `PHP_MEMORY_LIMIT` - PHP memory limit in megabytes. Example: `100`
* `PHP_POST_MAX_SIZE` - PHP POST maximum size in megabytes. Example: `50`
* `PHP_UPLOAD_MAX_FILESIZE` - PHP upload maximum file size in megabytes. Example: `100`
* `COMPOSER_DIRECTORY` - Path to where your  `composer.json` file lives. Example: `/var/www`
* `LARAVEL` - Is this a Laravel application. If you set this to `1` then set your composer directory too. Default `0`
* `RUN_MIGRATIONS` - Run Laravel migrations. (Will only work IF LARAVEL = 1). Default: `0`



## Dockerize templating

```
dockerize -template src_dir:dest_dir
```

* `PHP_DISPLAY_ERRORS` - Display php-fpm errors (on/off)
* `FPM_LOG_LEVEL` - php-fpm log level (warning for production, notice for dev/staging)
* `PHP_MEMORY_LIMIT` - php memory limit (default 128M)
* `PHP_POST_MAX_SIZE` - php post max size (default 100M)
* `PHP_UPLOAD_MAX_FILESIZE` - php upload max file size (default 100M)
