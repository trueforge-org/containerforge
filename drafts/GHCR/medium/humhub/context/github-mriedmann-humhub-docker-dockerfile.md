# Upstream Dockerfile: mriedmann/humhub-docker @ 6bb3dc908c7af3a930d500397d9394280cd55753

Source URL(s): https://raw.githubusercontent.com/mriedmann/humhub-docker/6bb3dc908c7af3a930d500397d9394280cd55753/Dockerfile (fetched 2026-11-27; blob URL same file)

## Build args
- HUMHUB_VERSION, VCS_REF, BUILD_DEPS (nodejs, npm, composer, php82-* extensions, tzdata), RUNTIME_DEPS (ca-certificates curl imagemagick libintl php82-* incl php82-fpm, php82-pecl-imagick, php82-sqlite3, supervisor, sqlite, tzdata)

## Stages
1. `builder`: `FROM docker.io/library/alpine:3.19.4`. `ADD https://github.com/humhub/humhub/archive/v${HUMHUB_VERSION}.tar.gz` -> /usr/src; extract to /usr/src/humhub. `composer install --no-dev --optimize-autoloader --no-scripts`; `npm install grunt grunt-cli`; `grunt build-assets`; rm node_modules.
2. `base`: `FROM docker.io/library/alpine:3.19.4`. apk RUNTIME_DEPS; gettext envsubst copied to /usr/local/bin. ENV PHP_POST_MAX_SIZE=16M, PHP_UPLOAD_MAX_FILESIZE=10M, PHP_MAX_EXECUTION_TIME=60, PHP_MEMORY_LIMIT=1G, PHP_TIMEZONE=UTC. Source copied to /var/www/localhost/htdocs/ chown 100:101. `.version` = v${HUMHUB_VERSION}. `COPY base/ /`, `docker-entrypoint.sh`. VOLUME /var/www/localhost/htdocs/uploads, /var/www/localhost/htdocs/protected/config, /var/www/localhost/htdocs/protected/modules. `ENTRYPOINT ["/docker-entrypoint.sh"]`, `CMD ["supervisord","-n","-c","/etc/supervisord.conf"]`. No USER line (runs as root).
3. `humhub_phponly`: fcgi, `COPY phponly/ /`; ADD php-fpm-healthcheck from renatomefi/php-fpm-healthcheck master (unpinned); group nginx 101, user nginx uid 100. `EXPOSE 9000`.
4. `humhub_nginx`: `FROM docker.io/library/nginx:1.27.2-alpine`. ENV NGINX_CLIENT_MAX_BODY_SIZE=10m, NGINX_KEEPALIVE_TIMEOUT=65, NGINX_UPSTREAM=humhub:9000. `COPY nginx/ /`, source copied from builder.
5. `humhub_allinone`: base + nginx, `EXPOSE 80`.

## Ports
- 9000 (php-fpm, phponly), 80 (allinone)

## Users / UIDs
- nginx uid 100, gid 101 (files chown 100:101). Upstream image does not set USER.

## Gotchas
- Healthcheck script fetched from unpinned master branch at build time.
- Entrypoint `docker-entrypoint.sh` and `base/`, `phponly/`, `nginx/` overlays not fetched in this pass.
