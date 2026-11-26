# cameronurnes/emby-sync (upstream, GitHub)

## Source URL(s) + date
- https://raw.githubusercontent.com/cameronurnes/emby-sync/63bd8b3/Dockerfile (fetched 2026-11-26)
- https://raw.githubusercontent.com/cameronurnes/emby-sync/63bd8b3/README.md
- https://raw.githubusercontent.com/cameronurnes/emby-sync/63bd8b3/boot.sh
- https://raw.githubusercontent.com/cameronurnes/emby-sync/63bd8b3/config.py
- https://raw.githubusercontent.com/cameronurnes/emby-sync/HEAD/requirements.txt (HEAD, not pinned commit)
- https://api.github.com/repos/cameronurnes/emby-sync/releases/latest: 404 (no releases exist; no alternative tried)

## What it is
Flask web app (Emby sync loop) that keeps Emby clients in sync for playback. Requires an external Emby server.

## Install/build steps (upstream Dockerfile)
- `FROM python:3.7-alpine`
- `RUN adduser -D emby-sync`; `WORKDIR /home/emby-sync`
- `COPY requirements.txt requirements.txt`
- `RUN python -m venv venv`
- `RUN venv/bin/pip install -r requirements.txt`
- `RUN venv/bin/pip install gunicorn`
- `COPY app app`, `COPY migrations migrations`, `COPY emby-sync.py config.py boot.sh ./`
- `RUN chmod +x boot.sh`
- `RUN chown -R emby-sync:emby-sync ./`

## Runtime deps
- Python 3.7 (upstream). requirements.txt pinned (2020-era): Flask==1.1.2, Flask-APScheduler==1.11.0, Flask-Bootstrap==3.3.7.1, Flask-Login==0.5.0, Flask-Migrate==2.5.3, Flask-SQLAlchemy==2.4.4, Flask-WTF==0.14.3, SQLAlchemy==1.3.18, alembic==1.4.2, APScheduler==3.6.3, Werkzeug==1.0.1, Jinja2==2.11.2, requests==2.24.0, click==7.1.2, WTForms==2.3.3, plus dominate, tzlocal==2.1, visitor==0.1.3, and others (full list in requirements.txt).
- gunicorn (installed separately, unpinned).

## Entrypoint/flags
- `ENTRYPOINT ["./boot.sh"]`
- boot.sh (sh):
  ```
  source venv/bin/activate
  flask db upgrade
  exec gunicorn -b :5000 --access-logfile - --error-logfile - emby-sync:app
  ```
- `ENV FLASK_APP emby-sync.py` (Dockerfile).
- Gotcha: boot.sh uses relative `venv/` (requires cwd = `/home/emby-sync` as in upstream WORKDIR).

## Env vars (config.py and README)
| Var | Default | Notes |
| --- | --- | --- |
| SECRET_KEY | none (`os.environ.get`) | Flask secret AND Emby API key sent as X-Emby-Token (README: "an API key for your emby server") |
| EMBY_SERVER | none | Emby base URL (README: required) |
| DEFAULT_ROOM | Bacon Bar | config.py `os.environ.get(...) or 'Bacon Bar'` |
| INTERVAL | 3.0 | seconds, sync loop interval |
| BUFFER | 0 | buffer time; README: 10000000 = 1s |
| SYNC_LIMIT | 8 | seconds of allowed client drift |
| DATABASE_URL | `sqlite:///<app dir>/app.db` (via config.py fallback) | SQLAlchemy URI |
| FLASK_APP | emby-sync.py | Dockerfile ENV |

Dev-only: `HOST`, `PORT` (dev_start.py; not used in container).

## Ports
- 5000 (`EXPOSE 5000`; gunicorn bind `:5000`).

## Volumes/paths
- Upstream: none declared. App DB default under app dir (`app.db`).
- Upstream WORKDIR `/home/emby-sync`; `venv/` lives there.

## User/UID
- `USER emby-sync` (Dockerfile). User created with `adduser -D` (no fixed UID stated).

## Config files
- None; config.py reads env vars.

## Healthcheck
- None upstream.

## Version/asset naming
- No tags and no releases (releases/latest API: 404). Build pins commit `63bd8b3`.
- Docker Hub `lastelement21/emby-sync:latest`: last pushed 2023-10-11T21:42:33Z.

## Arch
- Not stated upstream. Docker Hub tag fetched but arch list not reviewed.

## Gotchas
- Python 3.7 and 2020-era pins (Flask 1.1.2, Werkzeug 1.0.1, SQLAlchemy 1.3.18): likely wheel/compat issues on newer Python.
- `boot.sh` runs `flask db upgrade` on every start before gunicorn.
- Chromecast cannot follow (README known issue); currently-playing display only works for movies (README).
