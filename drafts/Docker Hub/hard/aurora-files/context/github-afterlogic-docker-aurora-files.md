# afterlogic/docker-aurora-files (upstream Docker wrapper)

**Source URL(s) + fetch date:** https://github.com/afterlogic/docker-aurora-files/blob/master/Dockerfile (raw), https://raw.githubusercontent.com/afterlogic/docker-aurora-files/master/afterlogic.php, https://raw.githubusercontent.com/afterlogic/docker-aurora-files/master/config/nginx.conf · fetched 2026-11-26

## What it is
Docker image for Aurora Files: nginx + PHP-FPM 8.3 + supervisor on Alpine. Loosely derived from khromov/alpine-nginx-php8. Licence per Docker Hub page: MIT (see dockerhub summary).

## Install/build steps and build deps
- `FROM alpine:3.24.3`.
- apk: php83, php83-cli, php83-fpm, php83-fileinfo, php83-mysqli, php83-pdo, php83-pdo_mysql, php83-pdo_sqlite, php83-iconv, php83-mbstring, php83-curl, php83-dom, php83-xml, php83-gd, php83-exif, php83-zip, php83-xmlwriter, php83-xmlreader, php83-session, nginx, supervisor, curl, tzdata, mysql-client.
- COPY `config/nginx.conf` -> `/etc/nginx/nginx.conf`; `config/fpm-pool.conf` -> `/etc/php83/php-fpm.d/www.conf`; `config/php.ini` -> `/etc/php83/conf.d/custom.ini`; `config/supervisord.conf` -> `/etc/supervisor/conf.d/supervisord.conf`.
- `/var/www/html` created; chown nobody on `/var/www/html`, `/run`, `/var/lib/nginx`, `/var/log/nginx`.
- `WORKDIR /var/www/html`.
- `RUN wget -P /tmp https://afterlogic.org/download/aurora-files.zip` then `unzip -qq` into `/var/www/html`. (Direct zip download, unversioned URL; not fetched as a binary.)
- `COPY afterlogic.php /var/www/html/afterlogic.php`; chown nobody `/var/www/html/data`.
- `USER nobody`; `RUN php83 /var/www/html/afterlogic.php` (configures DB settings at build time).

## Runtime deps
PHP 8.3 with the extensions above; nginx; supervisor; mysql-client (DB is external, host `db`).

## Binaries/entrypoint/CLI flags
- `CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]` (no ENTRYPOINT).
- HEALTHCHECK: `curl --silent --fail http://127.0.0.1/fpm-ping` (timeout 10s).

## afterlogic.php (build-time configuration script)
- Includes `/var/www/html/system/autoload.php`.
- `\Aurora\System\Api::Init(true)`, `GetSettings()`, then sets via `SetValue`:
  - `DBHost` = `db:3306`
  - `DBName` = `afterlogic`
  - `DBLogin` = `afterlogic`
  - `DBPassword` = `docker_Bundle` (hardcoded in plain text)
- `Save()`, then `SyncModulesConfigs()` through the module manager.

## Env vars
None defined by the upstream image (no ENV, no ARG).

## Ports
`EXPOSE 80`. nginx listens on `[::]:80` and IPv4, `default_server`.

## Volumes/paths and persistent data
- No VOLUME.
- Web root `/var/www/html`. `data/` under it is writable (settings in `data/settings/config.json`). nginx denies `location ~ /data`.
- Logs: access to `/dev/stdout`, error to `/dev/stderr`.
- nginx temp paths under `/tmp` (`client_temp`, `proxy_temp_path`, `fastcgi_temp`, `uwsgi_temp`, `scgi_temp`). PID `/run/nginx.pid`.
- Supervisor pid `/run/supervisord.pid` (per plan).

## User/UID & permissions
Runs as `nobody` (USER nobody before the configure step). Chown for `/run`, `/var/lib/nginx`, `/var/log/nginx`.

## Config files and formats
nginx.conf (listen 80, root `/var/www/html`, `index.php index.html`, FastCGI to `127.0.0.1:9000` TCP, not a Unix socket); fpm pool `www.conf`; `php.ini` -> `custom.ini`; `supervisord.conf`; Aurora `data/settings/config.json`.

## Healthcheck/readiness endpoints
`/fpm-ping` and `/fpm-status`: allowed only from 127.0.0.1 (nginx). Upstream HEALTHCHECK uses `http://127.0.0.1/fpm-ping`.

## Version/release info
The Dockerfile does not pin an Aurora version; `wget` fetches the latest zip at build time.

## Arch support
Not stated.

## Gotchas
- nginx `client_max_body_size 0` (no upload limit).
- Error pages 500/502/503/504 serve `/50x.html` from `/var/lib/nginx/html`.
- Builds fetch the zip at build time, so the image content moves with the vendor link.
- Hardcoded DB credentials in `afterlogic.php`: upstream default, not a secret to reuse.

## Contradictions with plan.md
- plan.md section 1: Alpine 3.24.3, php83 + php83-fpm, nginx, supervisor, mysql-client; zip wget; `COPY afterlogic.php`; `EXPOSE 80`; no VOLUME, no ENV; HEALTHCHECK `curl http://127.0.0.1/fpm-ping`: all confirmed.
- plan.md section 1 PHP extension list: matches the apk list.
- plan.md section 1 says env vars: none, and `afterlogic.php` DB host `db:3306`, name `afterlogic`, login `afterlogic`, password `docker_Bundle`: confirmed.
