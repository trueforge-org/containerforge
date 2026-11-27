# mriedmann/humhub-docker: Dockerfile (commit 6bb3dc90)

Source URL(s): https://raw.githubusercontent.com/mriedmann/humhub-docker/6bb3dc908c7af3a930d500397d9394280cd55753/Dockerfile (fetched 2026-11-27; blob/ variant same file). HumHub upstream: https://github.com/humhub/humhub (releases HTML fetched), https://docs.humhub.org (fetched, no install facts extracted).

## Build stages
- ARG HUMHUB_VERSION, VCS_REF, BUILD_DEPS (alpine php82 + composer + nodejs/npm), RUNTIME_DEPS (alpine php82-fpm, imagemagick, sqlite, supervisor, php82 modules incl. gd, intl, ldap, pdo_mysql, imagick, apcu, sqlite3).
- builder: FROM docker.io/library/alpine:3.19.4. ADD https://github.com/humhub/humhub/archive/v${HUMHUB_VERSION}.tar.gz; composer install --no-dev --optimize-autoloader; npm install grunt grunt-cli; `grunt build-assets`; rm node_modules.
- base: FROM alpine:3.19.4; apk RUNTIME_DEPS; envsubst copied from gettext; PHP ENVs; /var/run/supervisor.sock 777; COPY humhub from builder (chown 100:101) to /var/www/localhost/htdocs/; copies humhub/ overlay; protected/config defaults to /usr/src/humhub/protected/config; writes /usr/src/humhub/.version; COPY base/ /; docker-entrypoint.sh; crontab nginx 600.
- VOLUME /var/www/localhost/htdocs/uploads, /protected/config, /protected/modules.
- ENTRYPOINT ["/docker-entrypoint.sh"]; CMD ["supervisord", "-n", "-c", "/etc/supervisord.conf"] (base/allinone).
- humhub_phponly: fcgi, COPY phponly/ /; php-fpm-healthcheck from renatomefi (master, not pinned); nginx uid 100 / gid 101; EXPOSE 9000.
- humhub_nginx: FROM docker.io/library/nginx:1.27.2-alpine; ENV NGINX_CLIENT_MAX_BODY_SIZE=10m, NGINX_KEEPALIVE_TIMEOUT=65, NGINX_UPSTREAM=humhub:9000; rm conf.d/*; COPY nginx/ /; COPY humhub app files chown nginx:nginx.
- humhub_allinone: apk nginx; EXPOSE 80.

## Env (base PHP defaults)
| Name | Value |
| --- | --- |
| PHP_POST_MAX_SIZE | 16M |
| PHP_UPLOAD_MAX_FILESIZE | 10M |
| PHP_MAX_EXECUTION_TIME | 60 |
| PHP_MEMORY_LIMIT | 1G |
| PHP_TIMEZONE | UTC |

## Ports
- phponly: 9000 (php-fpm). nginx: 80 (from nginx base). allinone: 80.

## Volumes
- /var/www/localhost/htdocs/uploads, /protected/config, /protected/modules.

## User/UID
- nginx user uid 100, group gid 101 (phponly/base). Files chowned 100:101.

## Version/asset naming
- Source tarball: github.com/humhub/humhub archive v${HUMHUB_VERSION}; version written to .version as v<ver>.

## Gotchas
- php-fpm-healthcheck fetched from master branch (unpinned).
- Base image alpine 3.19.4; nginx 1.27.2-alpine (not on Docker Hub first page of 10 tags, see dockerhub-nginx.md).
- supervisord/base/ and phponly/ overlays not fetched.
