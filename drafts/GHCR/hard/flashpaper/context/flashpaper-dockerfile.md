# FlashPaper docker/Dockerfile

Source URL: https://raw.githubusercontent.com/AndrewPaglusch/FlashPaper/7c986b3f712563c085762eba68cf29f744acc7ea/docker/Dockerfile (commit 7c986b3, fetched 2026-11-27; the commit the draft cites, not the v2.6.1 tree)

## Base
- `FROM php:8.5-fpm-alpine` (musl)

## Build steps
- RUN: `apk add --no-cache curl nginx`; `mkdir -p /var/www/html`
- `COPY . /var/www/html`
- RUN: `chmod -R 775 /var/www/html`; `chown -R nginx:nginx /var/www/html`
- RUN: copy `$PHP_INI_DIR/php.ini-production` to `php.ini`; `rm -rf /usr/local/etc/php-fpm.d`
- RUN: write `$PHP_INI_DIR/conf.d/upload-progress.ini` with `session.upload_progress.enabled = Off` (GHSA-6wmf-4rv5-p3rp)
- `COPY docker/php-fpm.conf /usr/local/etc/php-fpm.conf`
- `COPY docker/nginx.conf /etc/nginx/nginx.conf`
- `COPY docker/entrypoint.sh /entrypoint.sh`
- `COPY docker/settings.php /var/www/html/settings.php`
- RUN: `rm -rf /var/www/html/docker`; `mkdir -p /var/run/nginx /var/run/php-fpm /var/log/php`; `chown -R nginx:nginx /var/run/`; `chmod +x /entrypoint.sh`

## Volumes / entry
- VOLUME `/var/www/html/data`
- `ENTRYPOINT ["/bin/ash", "/entrypoint.sh"]`

## ENV / EXPOSE / USER
- No ENV, no ARG, no EXPOSE, no USER, no HEALTHCHECK.

## Gotchas
- Config files (php-fpm.conf, nginx.conf, settings.php) live under docker/ and are copied in; their contents are in separate summaries (flashpaper-nginx-conf.md).
- Runtime user for nginx is `nginx` (alpine package), not a numbered UID here.
