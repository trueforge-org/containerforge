# nicholaswilde/docker-blog Dockerfile (main)

Source: https://raw.githubusercontent.com/nicholaswilde/docker-blog/main/Dockerfile (fetched 2026-11-26)

## Stages
- `dl` stage: Ubuntu 20.04; args VERSION, CHECKSUM, FILENAME (default `<version>.tar.gz`); WORKDIR /tmp; `SHELL bash pipefail`
  - apt install pinned wget 1.20.3-1ubuntu1, ca-certificates 20210119~20.04.1 (no recommends)
  - mkdir /app; `wget --no-check-certificate` `https://github.com/m1k1o/blog/archive/${FILENAME}`; sha256 check vs CHECKSUM; extract strip-1 into /app
  - cleanup: delete Dockerfile, docker-compose.*, top-level *.md, .gitignore
- final stage: `php:7.4-apache`; args BUILD_DATE, VERSION; labels build_version, maintainer nicholaswilde
  - apt pinned: libcurl4-openssl-dev zlib1g-dev libpng-dev libjpeg-dev libwebp-dev libxpm-dev libfreetype6-dev (Debian buster-era versions)
  - docker-php-ext-configure gd (jpeg, webp, xpm, freetype); install curl gd pdo pdo_mysql; a2enmod rewrite
  - COPY --from=dl /app -> /var/www/html, --chown=33:33
- VOLUME /var/www/html/data
- No EXPOSE, ENV, USER, ENTRYPOINT, CMD (inherited)

## Gotchas
- Uses PHP 7.4 and no postgres/imagick; differs from upstream m1k1o Dockerfile (php 8.5)
