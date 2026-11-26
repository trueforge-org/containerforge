# m1k1o/blog Dockerfile at commit f778915ab85f7ea86e1f35e60e5acecfbc90a15f

Source: https://raw.githubusercontent.com/m1k1o/blog/f778915ab85f7ea86e1f35e60e5acecfbc90a15f/Dockerfile (fetched 2026-11-26)

## Base
- Single stage: `php:8.5-apache-trixie`
- No ARG, ENV, WORKDIR, USER, EXPOSE, ENTRYPOINT, CMD (all inherited from base)

## Steps (one RUN, `set -eux`)
- apt-get update; install `--no-install-recommends`:
  - libpq-dev
  - zlib1g-dev libpng-dev libjpeg62-turbo-dev libwebp-dev libxpm-dev libfreetype-dev
  - libzip-dev
  - libmagickwand-7.q16-10 libheif-plugin-libde265 libmagickwand-dev
- rm /var/lib/apt/lists/*
- `docker-php-ext-configure gd --enable-gd --with-jpeg --with-webp --with-xpm --with-freetype`
- `docker-php-ext-install gd pdo_mysql pdo_pgsql exif zip` (curl, pdo built into base)
- `pecl install imagick`; `docker-php-ext-enable imagick`
- `apt-get purge -y --auto-remove libmagickwand-dev`
- `a2enmod rewrite`

## Files
- COPY build context -> /var/www/html with `--chown=33:33`
- VOLUME /var/www/html/data

## Gotchas
- No download URLs; packages from apt and PECL only
- Does not install pdo_sqlite explicitly (default DB is SQLite per config)
