# GitHub: beromir/Servas Dockerfile (v1.1.3 commit 088eaa3, v1.2.0), entrypoint, env example, license, release

Source URL(s): api contents Dockerfile?ref=088eaa3... and ?ref=v1.2.0; api contents docker-entrypoint.sh and .env.example?ref=088eaa3...; api repos/beromir/Servas/license; api releases/tags/v1.1.3 (fetched 2026-11-27)

## Release / license
- Release `v1.1.3`, published 2026-10-28T17:35:47Z, no assets.
- License: GPL-3.0 (GitHub API SPDX).

## Upstream Dockerfile (v1.1.3, commit 088eaa3)
- Stage `application_builder`: `FROM dunglas/frankenphp:1.13.4-php8.4.27-alpine`; `install-php-extensions @composer`; `composer install --optimize-autoloader --no-dev --no-plugins --no-scripts`; `composer dump-autoload --no-dev --no-plugins --classmap-authoritative`.
- Stage `asset_builder`: `FROM node:24.22-alpine`; copies package*.json, .npmrc, vite.config.js, resources; `npm install && npm run build`.
- Final: `FROM dunglas/frankenphp:1.13.4-php8.4.27-alpine`; `ENV SERVER_NAME=:80`; php.ini-production -> php.ini; `install-php-extensions pdo_mysql mysqli opcache bcmath`; `apk add mariadb-client sqlite`; COPY app, vendor, bootstrap/cache, public/build; COPY ./Caddyfile to /etc/caddy/Caddyfile; custom php ini and php-fpm conf; `/var/cache/php/opcache` (700); `/app/database/sqlite`; `ENTRYPOINT ["/docker-entrypoint.sh"]`. No USER, no EXPOSE, no VOLUME.

## Upstream Dockerfile (v1.2.0)
- Same stage layout; base changed to `dunglas/frankenphp:1.13.6-php8.5.13-alpine` (application_builder and final); asset builder still `node:24.22-alpine`; `ENV SERVER_NAME=:80`; `ENTRYPOINT ["/docker-entrypoint.sh"]`.

## docker-entrypoint.sh (v1.1.3 commit 088eaa3)
- If `/app/database/sqlite/database.sqlite` missing: touch it.
- `cd /app`; `php artisan migrate --force`; `php artisan config:cache`; `php artisan view:cache`; `frankenphp run --config /etc/caddy/Caddyfile`.

## .env.example (088eaa3)
- APP_NAME=Servas, APP_ENV=local, APP_KEY= (empty), APP_DEBUG=true, APP_URL=http://localhost, SERVAS_ENABLE_REGISTRATION=true, SERVAS_SHOW_APP_VERSION=true, LOG_CHANNEL=stack, LOG_LEVEL=debug, DB_CONNECTION=mysql, DB_HOST=127.0.0.1, DB_PORT=3306, DB_DATABASE=laravel, DB_USERNAME=root, DB_PASSWORD=, SESSION_DRIVER=database, CACHE_DRIVER=file, QUEUE_CONNECTION=sync, FILESYSTEM_DISK=local, SESSION_LIFETIME=120, REDIS_*, MAIL_* (mailer smtp, host mailhog), AWS_*, PUSHER_*, BROADCAST_DRIVER=log.

## Ports
- 80/tcp (Caddy `:80`). Non-root cannot bind 80 without change.

## Volumes/paths
- `/app/database/sqlite` (SQLite file), `/app/bootstrap/cache`, `storage/` (sessions, logs, cache), `/var/cache/php/opcache`.

## User/UID
- None set in Dockerfile: runs as root.

## Runtime deps
- FrankenPHP (Caddy + PHP), PHP extensions pdo_mysql, mysqli, opcache, bcmath, mariadb-client, sqlite. MariaDB/MySQL external or SQLite.

## Gotchas
- Upstream images are Alpine (musl).
- Entrypoint runs migrations on every start.
