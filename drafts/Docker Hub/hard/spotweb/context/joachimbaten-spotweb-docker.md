# joachimbaten/spotweb-docker (Dockerfile, entrypoint, config scripts, README)

Source URL(s): https://github.com/joachimbaten/spotweb-docker/blob/5c930ba/Dockerfile (raw); https://github.com/joachimbaten/spotweb-docker (README, raw master); follow-ups at 5c930ba: entrypoint.sh, config/root/init_db.sh, config/root/retrieve_spots.sh; config/ tree listing (WebFetch). Fetched 2026-11-26.

## Dockerfile
- `FROM alpine:latest` (unpinned)
- apk runtime: bash curl libldap libsasl mariadb-client postgresql-client nginx supervisor; php82 + php82-{fpm,curl,dom,gettext,xml,simplexml,zip,zlib,gd,openssl,mysqli,pdo,pdo_mysql,pgsql,pdo_pgsql,sqlite3,pdo_sqlite,json,mbstring,ctype,opcache,session}
- Spotweb: `git clone --depth=1 --branch develop https://github.com/spotweb/spotweb.git /app` (DEVELOP branch, not tag 1.5.4); `mkdir -m777 /app/cache`; git removed after
- cron dirs: `/etc/periodic/1min`, `/etc/periodic/5min`; root crontab lines run-parts for both
- `COPY /config /`; `COPY entrypoint.sh /entrypoint.sh`
- `chown -R nginx: /app`; `chmod +x /entrypoint.sh`
- `EXPOSE 80`; `ENTRYPOINT [ "sh", "/entrypoint.sh" ]`
- Runs as root (no USER line); nginx user `nginx`.

## entrypoint.sh
- `TZ` default `Europe/Amsterdam`; sed sets `date.timezone` in `/etc/php82/conf.d/spotweb.ini`
- `/root/init_db.sh` (fail -> exit 1)
- Cron: if `/etc/periodic/${SPOTWEB_RETRIEVE}` exists, copies `/root/retrieve_spots.sh` into it (else warning, skipped)
- `/usr/bin/supervisord` (nginx + php-fpm)

## config/root/init_db.sh
- Requires DB_ENGINE (`pdo_mysql` or `pdo_pgsql`), DB_HOST, DB_PORT, DB_USER, DB_PASSWORD, DB_DATABASE, DB_SCHEMA
- Polls DB 10 x (5 s sleep); exit 1 if unreachable
- Writes `/app/dbsettings.inc.php` (`$dbsettings[...]`), via tee
- If `select count(*) from settings` fails: `php82 /app/bin/init-db.php`; else `php82 /app/bin/upgrade-db.php`

## config/root/retrieve_spots.sh
- `/usr/bin/php82 /app/retrieve.php`

## README env (upstream repo)
| Variable | Sample | Notes |
| --- | --- | --- |
| TZ | Europe/Brussels | PHP timezone |
| SPOTWEB_SYSTEMTYPE | single | single / shared / public |
| SPOTWEB_USERNAME | myawesomeuser | admin |
| SPOTWEB_PASSWORD | ****** | admin |
| SPOTWEB_FIRSTNAME | demo | admin |
| SPOTWEB_LASTNAME | spotweb | admin |
| SPOTWEB_MAIL | demo@spotweb.com | admin |
| SPOTWEB_RETRIEVE | 15min | cron folder name (1min, 5min, hourly, daily, weekly, monthly per DH page) |
| DB_ENGINE | pdo_pgsql | pdo_pgsql or pdo_mysql |
| DB_HOST | db | |
| DB_PORT | 5432 | |
| DB_DATABASE | spotweb | |
| DB_USER | spotweb | |
| DB_PASSWORD | ******* | |
| DB_SCHEMA | public | |

- Newsserver settings are NOT env vars; set in UI after start.
- Init only creates admin/system type on first run; later runs do not alter them.
- Compose example in repo starts PostgreSQL alongside.

## Ports / volumes / user
- Port 80 (EXPOSE). No VOLUME, no UID set. Volumes: not documented in README.
