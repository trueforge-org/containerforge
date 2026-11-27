# Upstream Dockerfile: timothepoznanski/poznote (commit 5db51e94)

Source URL(s) + date:
- https://raw.githubusercontent.com/timothepoznanski/poznote/5db51e94dfa0f6f204f267505153cf5fd143feb2/Dockerfile (2026-11-27)
- https://github.com/timothepoznanski/poznote/blob/5db51e94.../Dockerfile: raw variant used

What it is: Alpine-based PHP-FPM + nginx + supervisord app. One `base` stage shared by two final targets: `rootless` and `default`.

Base: `FROM php:8.5.12-fpm-alpine3.23 AS base` (pinned for CVE floor 8.5.12).

Base stage:
- apk runtime: nginx, sqlite-libs, libzip, libcurl, ca-certificates, supervisor. Build deps (`$PHPIZE_DEPS`, sqlite-dev, libzip-dev, curl-dev) removed after `docker-php-ext-install pdo pdo_sqlite zip curl`.
- Copies configs: `docker/nginx/default.conf` -> `/etc/nginx/http.d/default.conf`; `docker/php-fpm/www.conf` -> `/usr/local/etc/php-fpm.d/www.conf`; `docker/php/php.ini` -> `/usr/local/etc/php/php.ini`; `docker/supervisor/supervisord.conf` -> `/etc/supervisor/conf.d/supervisord.conf`.
- `apk upgrade --no-cache`, `WORKDIR /var/www/html`
- `COPY docker/init.sh /usr/local/bin/init.sh`; writes `/var/www/html/version.php` (APP_VERSION define)
- LABELs: build_date, version, org.opencontainers.image.* (source, url, licenses="Open Source")
- `CMD ["/bin/sh", "-c", "/usr/local/bin/init.sh && exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf"]`

Rootless target (`FROM base AS rootless`, USER poznote):
- `addgroup -g 1000 poznote`, `adduser -u 1000 -G poznote -s /bin/sh -D poznote`
- sed patches: nginx `listen 80;` -> `listen 8080;`; drop `user` in `/etc/nginx/nginx.conf`; drop `user=root|www-data` in supervisord.conf; drop `user`, `group`, `listen.owner`, `listen.group` in php-fpm www.conf
- `mkdir -p /var/log/supervisor /run/nginx`; `chown -R poznote:poznote /var/log /var/lib/nginx /run`
- chown poznote on `www.conf`, `php.ini`, `default.conf` (init.sh rewrites them)
- `COPY --chown=poznote:poznote ./src /var/www/html`; `install -d -o poznote /var/www/html/data`
- `EXPOSE 8080`, `USER poznote`

Default target (`FROM base AS default`, root, www-data): `EXPOSE 80`, copies src as www-data. Not used by the chart.

Env vars read by init.sh (from README and Dockerfile comments):
| Name | Effect | Default |
| --- | --- | --- |
| POZNOTE_PHP_FPM_MAX_CHILDREN | pm.max_children | 10 |
| POZNOTE_PHP_MEMORY_LIMIT | memory_limit MB | 512 |
| POZNOTE_LISTEN_PORT | nginx listen port | 80 (default target) |

Ports: 8080 (rootless), 80 (default).

Volumes/paths: `/var/www/html/data` (user data, created writable). Runtime dirs `/var/log`, `/var/lib/nginx`, `/run`.

User/UID: rootless uid/gid 1000 (`poznote`). Default: www-data for app files.

Gotchas:
- Rootless target cannot chown at startup: host bind mounts must be owned by 1000 before start (README).
- `init.sh` runs as the rootless user and must write to the three config files chowned at build time.
- Build labels use `org.opencontainers.image.licenses="Open Source"`, not an SPDX id.
