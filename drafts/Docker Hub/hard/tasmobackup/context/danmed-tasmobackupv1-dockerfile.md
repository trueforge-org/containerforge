# danmed/TasmoBackupV1 Dockerfile

Source URL: https://raw.githubusercontent.com/danmed/TasmoBackupV1/59f8a66bafdc3cf5eb8255d58ceacbba33cd3bd1/Dockerfile (pinned commit, fetched 2026-11-26)
Blob URL: https://github.com/danmed/TasmoBackupV1/blob/59f8a66bafdc3cf5eb8255d58ceacbba33cd3bd1/Dockerfile

## Base / args
- `ARG BUILD_FROM=docker.patrickdk.com/docker-php-nginx:7.3`, `ARG BUILD_FROM_PREFIX`
- `FROM ${BUILD_FROM}`
- ARGs: BUILD_ARCH, QEMU_ARCH, BUILD_DATE, BUILD_REF, BUILD_VERSION
- WORKDIR /

## Copy
- `COPY install.sh qemu-${QEMU_ARCH}-static* /usr/bin/`
- `COPY --chown=www-data . /var/www/html/`

## ENV (nginx tuning)
| Var | Value |
| --- | --- |
| NGINX_SENDFILE | off |
| NGINX_WORKER_PROCESSES | 1 |
| NGINX_WORKER_CONNECTIONS | 200 |
| NGINX_KEEPALIVE_TIMEOUT | 65 |
| NGINX_PROXY_TIMEOUT | 2000 |
| NGINX_LOG_NOTFOUND | off |
| NGINX_LOG_ACCESS | off |
| NGINX_GZIP_STATIC | on |

## RUN (build steps)
- Removes `/etc/php*/conf.d/*brotli.ini`; removes mcrypt.ini if module missing.
- Symlinks `/usr/bin/php` to newest `php[0-9]*` if absent; `php -v`.
- Compiles `/var/www/html/locale/*/LC_MESSAGES/*.po` to `.mo` with msgfmt.
- In `/var/www/html/resources`: gzip -9 `*.js` and `*.css` (kept), chown www-data.
- Deletes `/var/www/html/install.sh` and `qemu-*-static`.
- Writes `/etc/nginx/vhost/server` (cache expiry: css/js 1h, images 1d; deny `/\.`).
- `chmod 755 /usr/bin/install.sh`.
- Cron: `/etc/crontabs/root` runs `wget http://localhost/backupall.php?docker=true` every hour at minute 8.

## Entrypoint / ports
- `CMD ["/usr/bin/install.sh", "/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]`
- No EXPOSE, VOLUME, USER, HEALTHCHECK, ENTRYPOINT in file. Port 80 served by nginx (per README/Docker Hub).

## Labels
- maintainer Dan Medhurst; io.hass.* and org.label-schema.* (name TasmoBackup, url github danmed/TasmoBackupV1).
