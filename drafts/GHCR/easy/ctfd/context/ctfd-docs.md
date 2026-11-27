# CTFd docs (docs.ctfd.io)

## Source URL(s) + date
- https://docs.ctfd.io/ (main, fetched 2026-11-27; returned navigation only, no content)
- https://docs.ctfd.io/docs/deployment/installation (follow-up, fetched 2026-11-27)
- https://docs.ctfd.io/docs/settings/overview (follow-up, fetched 2026-11-27)

## What it is
CTFd is a Capture The Flag framework. Docs cover deployment, settings and plugins.

## Install/deploy (installation page)
- Recommended server: dual core, 1 GB RAM minimum; quad core, 2 GB recommended.
- Docker Compose is the simplest route. Compose env example: `SECRET_KEY`, `UPLOAD_FOLDER=/var/uploads`, `LOG_FOLDER=/var/log/CTFd`, `DATABASE_URL=mysql+pymysql://...`, `REDIS_URL=redis://cache:6379`, `WORKERS=4`. Serves on port 8000.
- Secret key alternative: `head -c 64 /dev/urandom > .ctfd_secret_key` in the repo root.
- WSGI: gunicorn is the default server, gevent worker class.
- Database: MySQL recommended. MariaDB and SQLite tested. Postgres "at your own peril". Without a DB server, SQLite is created by default. CTFd needs a JSON-capable DB.
- Cache: Redis recommended. Without one, filesystem cache in `.data` (slow).
- Debug: `python serve.py` (Flask dev server, not for load).

## Settings overview
- Settings are edited inside CTFd (admin UI). Sub-pages include accounts, emails, security, single sign-on, themes, user modes.

## Gotchas
- Docs do not list the full env var set. Env names used by the entrypoint are in `ctfd-3.8.9-docker-entrypoint.md`.
- Docs do not state a healthcheck.
