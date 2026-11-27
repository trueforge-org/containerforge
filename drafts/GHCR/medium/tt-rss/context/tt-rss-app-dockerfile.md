# tt-rss app image Dockerfile (.docker/app)

Source URL(s): https://raw.githubusercontent.com/tt-rss/tt-rss/03628f0aa3c4a86e960ddd61b5ba372cd3a27b50/.docker/app/Dockerfile ; startup.sh from same commit (fetched 2026-11-27)

## What it is
- Alpine-based PHP-FPM app container for tt-rss (GHCR ghcr.io/tt-rss/tt-rss).

## Build
- `FROM alpine:3.24.4`, `EXPOSE 9000/tcp`.
- ARG ALPINE_MIRROR (optional apk mirror rewrite).
- `PHP_SUFFIX=85` -> packages php85 + php85-{ctype,curl,dom,exif,fileinfo,fpm,gd,iconv,intl,json,mbstring,openssl,pcntl,pdo,pdo_pgsql,pecl-apcu,pecl-xdebug,phar,posix,session,simplexml,sockets,sodium,tokenizer,xml,xmlwriter,zip}.
- apk add: ca-certificates dcron git postgresql-client rsync sudo tzdata.
- php-fpm: listen 9000, user/group app, status_path /status on port 9001, memory_limit 256M.
- `COPY . /src/tt-rss/` (SRC_DIR); clones tt-rss-plugin-nginx-xaccel into plugins.local/.
- ADD startup.sh, update.sh, updater.sh, dcron.sh, backup.sh (-> /etc/periodic/weekly/backup), index.php, config.docker.php into SCRIPT_ROOT=/opt/tt-rss.

## Entrypoint
- `CMD ["/bin/sh", "-c", "/opt/tt-rss/startup.sh"]` (no ENTRYPOINT). startup.sh ends with `touch .app_is_ready` then `exec /usr/sbin/php-fpm85 --nodaemonize --force-stderr`.

## Env vars (defaults)
| Var | Default |
| --- | --- |
| SCRIPT_ROOT | /opt/tt-rss |
| SRC_DIR | /src/tt-rss/ |
| APP_INSTALL_BASE_DIR | /var/www/html |
| PHP_SUFFIX | 85 |
| OWNER_UID / OWNER_GID | 1000 / 1000 |
| PHP_WORKER_MAX_CHILDREN | 5 |
| PHP_WORKER_MEMORY_LIMIT | 256M |
| ADMIN_USER_PASS | "" (applied each startup) |
| ADMIN_USER_ACCESS_LEVEL | "" |
| AUTO_CREATE_USER / _PASS / _ACCESS_LEVEL / _ENABLE_API | "" / "" / "0" / "" |
| TTRSS_NO_STARTUP_PLUGIN_UPDATES | "" |
| TTRSS_XDEBUG_ENABLED / _HOST / _PORT | "" / "" / 9000 |
| TTRSS_DB_HOST / TTRSS_DB_PORT | db / 5432 |
| TTRSS_PHP_EXECUTABLE | /usr/bin/php85 |
| TTRSS_PLUGINS | "auth_internal, note, nginx_xaccel" |
| CI_COMMIT_BRANCH / _SHORT_SHA / _TIMESTAMP / _SHA | build ARGs |
Also: `<VAR>__FILE` secret-file convention supported by startup.sh.

## startup.sh behaviour
- Waits for Postgres via pg_isready on TTRSS_DB_HOST/USER/PORT.
- Creates user/group `app` (uid/gid from OWNER_*) if missing.
- Copies index.php to APP_INSTALL_BASE_DIR; rsyncs SRC_DIR -> /var/www/html/tt-rss (skip if SKIP_RSYNC_ON_STARTUP set; excludes cache, lock, plugins.local, themes.local, templates.local).
- Creates cache/lock/plugins.local/themes.local/templates.local and cache subdirs.
- Copies config.docker.php -> tt-rss/config.php; runs update.php --update-schema=force-yes; sets admin password from ADMIN_USER_PASS (random if empty); applies ADMIN_USER_ACCESS_LEVEL and AUTO_CREATE_USER.
- Updates local plugins via git unless TTRSS_NO_STARTUP_PLUGIN_UPDATES set; migrates legacy tt-rss.org/gitlab origins to GitHub.

## Ports
- 9000 (php-fpm), 9001 status (pm.status_listen).

## Volumes/paths
- /var/www/html (shared web root with nginx), /opt/tt-rss/config.d, /tt-rss working copy at /var/www/html/tt-rss, /tmp/error.log.

## User/UID
- Runs as root for startup, php-fpm workers as `app` (OWNER_UID 1000 default).

## Healthcheck
- None in this Dockerfile (nginx image has one).

## Arch / Gotchas
- `.app_is_ready` is touched just before php-fpm exec (chart startup/readiness probe checks it).
- Working copy is written into the PVC at /var/www/html; startup is root-dependent (chown, adduser, apk-level setup) — not read-only-rootfs friendly as-is (chart sets readOnlyRootFilesystem false).
