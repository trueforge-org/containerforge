# Dispatcharr/Dispatcharr docker/entrypoint.sh (tag v0.34.1)

Source URL(s) + fetch date:
- https://raw.githubusercontent.com/Dispatcharr/Dispatcharr/v0.34.1/docker/entrypoint.sh · 2026-11-26

## Env vars with defaults
- `POSTGRES_DB` dispatcharr; `POSTGRES_USER` dispatch; `POSTGRES_PASSWORD` secret (empty in modular when `POSTGRES_SSL=true`); `POSTGRES_PORT` 5432; `POSTGRES_HOST` (aio: unset/localhost -> `/var/run/postgresql`; else localhost); `POSTGRES_SSL_MODE` verify-full (only with POSTGRES_SSL=true).
- `DISPATCHARR_ENV` aio; `DISPATCHARR_PORT` 9191; `DISPATCHARR_LOG_LEVEL` INFO (uppercased); `DISPATCHARR_TIME_ZONE` (falls back to TZ, then UTC); `DISPATCHARR_LOG_DIR` (default `/data/logs`); `DISPATCHARR_NOFILE` 65536; `DISPATCHARR_DEBUG` (checked for true).
- `REDIS_HOST` localhost; `REDIS_PORT` 6379; `REDIS_DB` 0; `REDIS_USER`/`REDIS_PASSWORD` empty; `REDIS_IDLE_TIMEOUT` 300; `REDIS_MAX_CONNECTIONS` 50.
- `UWSGI_WORKERS` 1 if debug else 4 (1-20); `UWSGI_NICE_LEVEL` 0; `CELERY_NICE_LEVEL` absolute 5 (converted to offset); `CELERY_MAX_WORKERS` 6; `CELERY_MIN_WORKERS` 1 (error if min > max).
- `LIBVA_DRIVER_NAME` exported if set; `USE_LEGACY_NUMPY` checked for true.

## Files written / dirs
- `/data/jwt`: generated if missing (umask 077, `secrets.token_urlsafe(64)`), read into `DJANGO_SECRET_KEY`.
- `/etc/profile.d/dispatcharr.sh`, `/etc/environment`, `/root/.bashrc` (upstream writes these; not needed rootless).
- `$LOG_FILE_DIR/config` created; `/data/.pg-client.key` fixed key path (TLS).
- `POSTGRES_DIR=/data/db` (aio).

## Privilege / users
- Sources `/app/docker/init/01-user-setup.sh` (PUID/PGID). chown for log dir and `dispatcharr.log`.
- Postgres, migrate, collectstatic and uwsgi run via `su - "$POSTGRES_USER" -c ...`.
- Init scripts in order: 01-user-setup, 05-log-collector, 00-fix-pg-ssl-key, 02-postgres, 03-init-dispatcharr, 99-init-dev (dev only), 04-check-hwaccel.

## Postgres
- aio: `pg_ctl -D ${POSTGRES_DIR} start -w -t 300 -o '-c port=${POSTGRES_PORT}'`, wait via `pg_isready -h ${POSTGRES_HOST} -p ${POSTGRES_PORT} -U ${POSTGRES_USER} -d template1` every 1s, then `promote_app_role` and `ensure_app_database`.
- modular: wait with `$PG_BINDIR/pg_isready ... -d "${POSTGRES_DB}" -q` every 1s, then `check_external_postgres_version || exit 1`.
- PG_BINDIR `/usr/lib/postgresql/${PG_VERSION}/bin` (highest version found).

## Redis
- modular: `python3 /app/scripts/wait_for_redis.py`. aio: uwsgi exec-pre.

## Startup
- nginx started in background (`nginx`), PID via pgrep.
- Migrations: `su - "$POSTGRES_USER" -c "cd /app && ${migrate_env}python manage.py migrate --noinput"` (migrate_env `DISPATCHARR_SKIP_REDIS_CACHE=1 ` outside modular).
- collectstatic: `su - "$POSTGRES_USER" -c "cd /app && python manage.py collectstatic --noinput"`.
- uwsgi config: dev -> `uwsgi.dev.ini`, debug -> `uwsgi.debug.ini`, modular -> `uwsgi.modular.ini`, else `uwsgi.ini`. Args `--ini $uwsgi_file` plus `--disable-logging` when not debug.
- Launch: `nice -n "$UWSGI_NICE_LEVEL" su - "$POSTGRES_USER" -c "ulimit -n $DISPATCHARR_NOFILE 2>/dev/null || true; cd /app && exec $VIRTUAL_ENV/bin/uwsgi $uwsgi_args" &`.
- Monitoring loop; on process exit it logs and runs cleanup. Cleanup sends TERM, waits 8s, KILL.

## Gotchas vs plan.md
- Upstream writes `/data/jwt` (plan matches).
- Upstream runs migrate and collectstatic at start (plan runs migrate in start.sh, collectstatic at build time: plan marks UNVERIFIED).
- Upstream exports `DJANGO_SECRET_KEY` from `/data/jwt` in celery too.
