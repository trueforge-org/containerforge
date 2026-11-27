# ellite/Wallos (Dockerfile)

Source URL(s) + date: https://raw.githubusercontent.com/ellite/Wallos/v5.11.2/Dockerfile and https://raw.githubusercontent.com/ellite/Wallos/df7ce2d687f2891e1bd9541685159fb44ec2df3d/Dockerfile (byte-identical), fetched 2026-11-27

## Build
- `FROM php:8.3-fpm-alpine`; WORKDIR `/var/www/html`.
- `apk upgrade`; apk add (no-cache): dumb-init, shadow, sqlite-dev, libpng(-dev), libjpeg-turbo(-dev), freetype(-dev), curl, autoconf, libgomp, icu-dev, icu-data-full, nginx, dcron, tzdata, libzip-dev, sqlite, libwebp-dev.
- PHP exts: `docker-php-ext-install pdo pdo_sqlite calendar`; enable pdo, pdo_sqlite; gd configured with freetype/jpeg/webp; install gd intl zip.
- `COPY . .` (app source); `COPY nginx.conf /etc/nginx/nginx.conf`; `COPY nginx.default.conf /etc/nginx/http.d/default.conf`; removes those two from webroot.
- `COPY cronjobs /etc/cron.d/cronjobs`; dos2unix, chmod 0644, crontab install, `mkdir /var/log/cron`.
- `chown -R www-data:www-data /var/www/html`; `chmod +x /var/www/html/startup.sh`.
- php-fpm: `pm.max_children = 15`, `pm.max_requests = 500` (zz-docker.conf); `upload_max_filesize = 256M`, `post_max_size = 256M` (wallos-uploads.ini).

## Runtime
- `EXPOSE 80`.
- `ENTRYPOINT ["dumb-init", "--"]`.
- `CMD ["/var/www/html/startup.sh"]` (starts php-fpm and nginx; startup.sh not fetched).
- `HEALTHCHECK --interval=2m --timeout=2s --start-period=20s --start-interval=5s --retries=3 CMD ["curl","-fsS","http://127.0.0.1/health.php"]` (needs Docker engine 25+).

## Runtime deps
- nginx, php-fpm 8.3 (alpine), dcron, dumb-init, sqlite, curl, ICU, libzip, gd libs.

## Ports
- 80 (nginx).

## Volumes/paths
- App at `/var/www/html`; upload logos under `/var/www/html/images/uploads/logos` and DB under `/var/www/html/db` (per chart mounts).

## User/UID
- Files owned by `www-data`. No USER directive (container runs as root by default; php-fpm/nginx handle users).

## Arch
- Base `php:8.3-fpm-alpine` (multi-arch official image).

## Gotchas
- Requires Docker engine 25+ for `--start-interval` in HEALTHCHECK.
- Not rootless: no USER directive; nginx/cron/startup need root.
