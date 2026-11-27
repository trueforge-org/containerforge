# CTFd 3.8.9 docker-entrypoint.sh

## Source URL(s) + date
- https://raw.githubusercontent.com/CTFd/CTFd/3.8.9/docker-entrypoint.sh (fetched 2026-11-27)

## Behaviour (bash, `set -euo pipefail`)
1. Defaults: `WORKERS=1`, `WORKER_CLASS=gevent`, `ACCESS_LOG=-`, `ERROR_LOG=-`, `WORKER_TEMP_DIR=/dev/shm`, `SECRET_KEY=""`, `SKIP_DB_PING=false`.
2. Secret key check: if no `.ctfd_secret_key` in cwd and `SECRET_KEY` empty: if `WORKERS > 1`, exit 1 with error. (One worker is allowed without a key.)
3. If `SKIP_DB_PING == "false"`: runs `python ping.py`. Any other value skips it.
4. `flask db upgrade`.
5. `echo "Starting CTFd"`; `exec gunicorn 'CTFd:create_app()' --bind 0.0.0.0:8000 --workers $WORKERS --worker-tmp-dir "$WORKER_TEMP_DIR" --worker-class "$WORKER_CLASS" --access-logfile "$ACCESS_LOG" --error-logfile "$ERROR_LOG"`.

## Env vars
| Name | Default | Use |
| --- | --- | --- |
| WORKERS | `1` | gunicorn workers |
| WORKER_CLASS | `gevent` | gunicorn worker class |
| ACCESS_LOG | `-` | access log path |
| ERROR_LOG | `-` | error log path |
| WORKER_TEMP_DIR | `/dev/shm` | gunicorn worker temp dir |
| SECRET_KEY | `""` | required if WORKERS > 1 and no `.ctfd_secret_key` |
| SKIP_DB_PING | `false` | skips `ping.py` when not `false` |

## Ports
- 8000/tcp (bind 0.0.0.0:8000)

## Gotchas
- `WORKER_TEMP_DIR` default is `/dev/shm` upstream. A read-only rootfs or a missing `/dev/shm` will break it.
- Secret-key file is read from the cwd, so the working directory matters.
- No healthcheck in the script.
