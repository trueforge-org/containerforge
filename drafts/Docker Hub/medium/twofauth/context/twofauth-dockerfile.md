# 2FAuth Dockerfile at tag v9.0.3

Source URL(s): https://raw.githubusercontent.com/Bubka/2FAuth/v9.0.3/Dockerfile (fetched 2026-11-27; GitHub API contents endpoint returned 403 rate limit, raw used instead)

## Build args (defaults)
| ARG | Default |
| --- | --- |
| ALPINE_VERSION | 3.24 |
| PHP_VERSION | 8.4-alpine${ALPINE_VERSION} |
| COMPOSER_VERSION | 2.9 |
| SUPERVISORD_VERSION | v0.7.3 |
| UID / GID | 1000 / 1000 |
| VERSION, CREATED, COMMIT | unknown / "an unknown date" / unknown |

## Stages
- `build-composer`, `composer` (composer:2.9), `supervisord` (`qmcgaw/binpot:supervisord-v0.7.3`).
- `vendor`: `php:8.4-alpine3.24`; installs gd, bcmath via `install-php-extensions`; `composer install --no-dev`.
- `test`: runs `/srv/vendor/bin/phpunit` (ENTRYPOINT), not the runtime image.
- Final: `alpine:3.24`.
  - apk: php84, php84-phar, php84-pdo_sqlite, php84-sqlite3, php84-pdo_mysql, php84-pdo_pgsql, php84-pgsql, php84-xml, php84-gd, php84-mbstring, php84-tokenizer, php84-fileinfo, php84-bcmath, php84-ctype, php84-dom, php-redis, php84-session, php84-openssl, php84-fpm, nginx
  - `ln -sf /usr/bin/php84 /usr/bin/php`
  - php-fpm pool: removes `user`, `group`, `listen.owner`, `listen.group` lines (runs as UID).
  - `/run/php`, `/var/log/php84` owned by UID:GID, mode 700.
  - nginx: `/etc/nginx/nginx.conf` replaced by `docker/nginx.conf`; `nginx -t` at build; pid and error log touched.
  - supervisord config copied to `/etc/supervisor/supervisord.conf` from `docker/supervisord.conf`.
  - `mkdir /2fauth` (chmod 700), `WORKDIR /srv` (chmod 700).
  - `USER ${UID}:${GID}` (non-root).
  - vendor copied to `/srv/vendor`; app source copied to `/srv`; `composer dump-autoload`.
  - ENTRYPOINT `/usr/local/bin/entrypoint.sh` (chmod 500), from `docker/entrypoint.sh`.

## ENV / LABEL
- ENV: `LOG_CHANNEL=daily`, `LOG_LEVEL=info`, `DB_CONNECTION=sqlite`, `DB_DATABASE=/srv/database/database.sqlite`, `WEBAUTHN_NAME=2FAuth`, plus `VERSION`, `CREATED`, `COMMIT`.
- LABEL: `org.opencontainers.image.*` (source https://github.com/Bubka/2FAuth, documentation hub.docker.com/r/2fauth/2fauth).

## Ports
- `EXPOSE 8000/tcp` (nginx listens 8000).

## Gotchas
- Default DB is sqlite, stored under `/2fauth` via symlink (see entrypoint).
- Read-only rootfs: entrypoint writes `/srv/database`, `/srv/storage` symlinks and `/2fauth`, so `/2fauth` must be writable; `/tmp` used by nginx temp paths.
- Build args `VERSION`/`COMMIT`/`CREATED` are set by CI.
