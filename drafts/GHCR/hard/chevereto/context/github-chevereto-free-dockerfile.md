# Upstream Dockerfile: rodber/chevereto-free httpd-php.Dockerfile

Source URL(s) + date: https://raw.githubusercontent.com/rodber/chevereto-free/1171863/httpd-php.Dockerfile (same file as https://github.com/rodber/chevereto-free/blob/1171863/httpd-php.Dockerfile), fetched 2026-11-27. Commit 1171863.

## Install/build steps
- `FROM composer:latest as composer`, `FROM php:7.4-apache`, `COPY --from=composer /usr/bin/composer /usr/local/bin/composer`.
- apt (one RUN, `--no-install-recommends`): libfreetype6-dev, libjpeg62-turbo-dev, libpng-dev, libwebp-dev, libgd-dev, libzip-dev, zip, unzip, imagemagick, libmagickwand-dev.
- `docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ --with-webp=/usr/include/`; `docker-php-ext-configure opcache --enable-opcache`.
- `docker-php-ext-install -j$(nproc) exif gd pdo_mysql zip opcache`; `pecl install imagick`; `docker-php-ext-enable imagick opcache`; `php -m`.
- Second RUN: apt rsync, inotify-tools; `a2enmod rewrite`.
- PHP ini written to `$PHP_INI_DIR/conf.d/php.ini`: log_errors On, error_log /dev/stderr, upload_max_filesize/post_max_size/max_execution_time/memory_limit from `${CHEVERETO_*}` env.
- `VOLUME /var/www/html/content`, `VOLUME /var/www/html/images`.
- `COPY . /var/www/html`; `RUN rm /var/www/html/sync.sh`; `composer install --working-dir=/var/www/html --prefer-dist --no-progress --classmap-authoritative --ignore-platform-reqs`; `chown www-data: /var/www/html -R`; `COPY sync.sh /var/www/sync.sh`; chmod +x.

## Runtime deps
- php 7.4 (apache module), composer packages (see composer file), imagemagick/imagick, gd, pdo_mysql, zip, exif, opcache, rsync, inotify-tools.

## Entrypoint/flags
- `CMD ["/bin/bash", "apache2-foreground"]` (upstream; the plan notes this is not a PATH binary, so do not copy it).

## Env vars (ENV defaults)
| Var | Default |
| --- | --- |
| CHEVERETO_SOFTWARE | chevereto (ARG) |
| CHEVERETO_TAG | free (ARG) |
| CHEVERETO_SERVICING | docker (ARG) |
| CHEVERETO_DB_HOST | mariadb |
| CHEVERETO_DB_USER | chevereto |
| CHEVERETO_DB_PASS | user_database_password |
| CHEVERETO_DB_NAME | chevereto |
| CHEVERETO_DB_TABLE_PREFIX | chv_ |
| CHEVERETO_DB_PORT | 3306 |
| CHEVERETO_DB_DRIVER | mysql |
| CHEVERETO_DB_PDO_ATTRS | [] |
| CHEVERETO_DEBUG_LEVEL | 1 |
| CHEVERETO_DISABLE_PHP_PAGES | 1 |
| CHEVERETO_DISABLE_UPDATE_HTTP | 1 |
| CHEVERETO_DISABLE_UPDATE_CLI | 1 |
| CHEVERETO_ERROR_LOG | /dev/stderr |
| CHEVERETO_IMAGE_FORMATS_AVAILABLE | JPG,PNG,BMP,GIF,WEBP |
| CHEVERETO_IMAGE_LIBRARY | gd |
| CHEVERETO_HTTPS | 1 |
| CHEVERETO_HOSTNAME | localhost |
| CHEVERETO_HOSTNAME_PATH | / |
| CHEVERETO_SESSION_SAVE_HANDLER | files |
| CHEVERETO_SESSION_SAVE_PATH | /tmp |
| CHEVERETO_UPLOAD_MAX_FILESIZE | 64M |
| CHEVERETO_POST_MAX_SIZE | 64M |
| CHEVERETO_MAX_EXECUTION_TIME | 30 |
| CHEVERETO_MEMORY_LIMIT | 512M |

## Ports
- None declared (no EXPOSE). Apache default 80 from php:apache base.

## Volumes/paths
- /var/www/html/content, /var/www/html/images (VOLUME), app at /var/www/html, sync script /var/www/sync.sh.

## User/UID
- Base php:apache runs as root for Apache start; files owned by www-data.

## Gotchas
- Base is php:7.4-apache (EOL PHP). `composer:latest` is unpinned.
- `RUN rm sync.sh` then later `COPY sync.sh` (file must exist in build context).
- `CHEVERETO_IMAGE_FORMATS_AVAILABLE` default is a plain comma list here; the v4 docs show a JSON-array form (see chevereto-v4-docs.md).
- Upstream CMD is not a valid executable.
