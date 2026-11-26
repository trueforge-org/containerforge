# Dispatcharr/Dispatcharr docker/entrypoint.celery.sh (tag v0.34.1)

Source URL(s) + fetch date:
- https://raw.githubusercontent.com/Dispatcharr/Dispatcharr/v0.34.1/docker/entrypoint.celery.sh · 2026-11-26

## Commands (exact)
- Beat: `celery --quiet -A dispatcharr beat -l info &`
- DVR worker: `nice -n "$NICE_LEVEL" celery --quiet -A dispatcharr worker -Q dvr -n dvr@%h --pool=threads --concurrency=20 -l info &`
- Default worker (foreground, last): `nice -n "$NICE_LEVEL" celery --quiet -A dispatcharr worker -Q celery,plugins -n default@%h --autoscale="$CELERY_MAX_WORKERS,$CELERY_MIN_WORKERS" -l info`

## Waits / checks before start
1. Waits for `/data/jwt` (1s poll, 120s timeout, exit 1 on timeout), then reads it into `DJANGO_SECRET_KEY` (strip CR/LF).
2. If `USE_LEGACY_NUMPY=true`, may reinstall NumPy from `/opt/numpy-*.whl` with `uv pip install`.
3. Sources `/app/docker/init/00-fix-pg-ssl-key.sh` with `FIXED_KEY_PATH=/data/.pg-client-celery.key`.
4. Loops `python manage.py migrate --check` every 2s, 300s timeout (exit 1).
5. Validates worker counts (integers 1-20, min <= max).
6. Negative NICE_LEVEL prints a SYS_NICE warning.

## Env vars
- Read: `CELERY_MAX_WORKERS` (6), `CELERY_MIN_WORKERS` (1), `CELERY_NICE_LEVEL` (5), `DISPATCHARR_TIME_ZONE` (TZ, then UTC), `DISPATCHARR_LOG_DIR` (`/data/logs`), `USE_LEGACY_NUMPY`, `VIRTUAL_ENV`.
- Set: `DISPATCHARR_TIME_ZONE`, `DISPATCHARR_LOG_ROLE=celery`, `DJANGO_SECRET_KEY`, `CELERY_MAX_WORKERS`, `CELERY_MIN_WORKERS`.

## Paths
- Reads `/data/jwt`; writes log dir `/data/logs` (default); `/data/.pg-client-celery.key`; sources `/dispatcharrpy/bin/activate`, `/app/docker/init/05-log-collector.sh`.
