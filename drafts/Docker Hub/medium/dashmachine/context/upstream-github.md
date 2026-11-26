# rmountjoy92/DashMachine (upstream, GitHub)

## Source URL(s) + date
- https://raw.githubusercontent.com/rmountjoy92/DashMachine/be50c2e763ae4e18f95855c18ba31c42199a4b3e/Dockerfile (fetched 2026-11-26)
- https://raw.githubusercontent.com/rmountjoy92/DashMachine/be50c2e763ae4e18f95855c18ba31c42199a4b3e/README.md
- https://raw.githubusercontent.com/rmountjoy92/DashMachine/be50c2e763ae4e18f95855c18ba31c42199a4b3e/requirements.txt
- https://api.github.com/repos/rmountjoy92/DashMachine/releases/latest

## What it is
Self-hosted Flask (Python 3) dashboard. Config and DB stored in a user data folder. Stale project (last image push 2020-09-22).

## Install/build steps (upstream Dockerfile)
- `FROM python:3.8-slim`
- apt: `inetutils-ping` (`--no-install-recommends`, lists removed)
- `COPY [ "requirements.txt", "/dashmachine/" ]`, `WORKDIR /dashmachine`
- `RUN pip install --no-cache-dir --progress-bar off -r requirements.txt`
- `COPY [ ".", "/dashmachine/" ]`

## Runtime deps
- Python 3.8 (upstream base). requirements.txt (all unpinned except none; listed): alembic, aniso8601, bcrypt, certifi, cffi, chardet, Click, Flask, Flask-Bcrypt, Flask-Caching, Flask-Login, Flask-RESTful, Flask-Script, Flask-SQLAlchemy, Flask-WTF, gunicorn, htmlmin, idna, itsdangerous, Jinja2, jsmin, Mako, MarkupSafe, Pillow, pycparser, python-dateutil, python-editor, pytz, requests, six, SQLAlchemy, urllib3, Werkzeug, WTForms, transmissionrpc, markdown2.
- No version pins in requirements.txt.
- `gunicorn` IS listed (unpinned).
- Pillow needs native build deps on some arches (not stated upstream).

## Entrypoint/flags
- No ENTRYPOINT.
- `CMD [ "gunicorn", "--bind", "0.0.0.0:5000", "wsgi:app" ]`

## Env vars
| Var | Default | Notes |
| --- | --- | --- |
| PRODUCTION | true | `ENV PRODUCTION=true` in upstream Dockerfile (code-reading not verified) |
| CONTEXT_PATH | unset | subfolder hosting, e.g. `/dash` (README `-e CONTEXT_PATH=/dash`) |

## Ports
- 5000 (`EXPOSE 5000`; gunicorn bind `0.0.0.0:5000`).

## Volumes/paths
- `VOLUME /dashmachine/dashmachine/user_data` (upstream). Holds `config.ini`, custom backgrounds and icons, SQLite database (README).
- App path upstream: `/dashmachine`.

## User/UID
- Upstream: root (no USER).

## Config files
- `dashmachine/user_data/config.ini` (edit in user data; restart container or click Save in Settings > Config).
- Config reference shown on settings page (info icon next to 'Config').

## Healthcheck
- None upstream.

## Default credentials
- README: default user `admin` (password is in README "Default user/password" section; not copied here).

## Version/asset naming
- Latest release (API): tag `v0.5-4.2`, name "Version 0.5-4", published 2020-05-30, no assets.
- Docker Hub `rmountjoy/dashmachine:latest`: amd64, digest sha256:497692b79838b042db0cb1d7ca8a28dfb20d0623fc7db705b8a42b055687e5a0, last pushed 2020-09-22T11:45:52Z.

## Arch
- Not stated. Upstream image amd64 only on Docker Hub tag listing.

## Gotchas
- Upstream image Python 3.8 (EOL).
- No dependency pins: builds float.
- README states CONTEXT_PATH for subfolder operation.
- `inetutils-ping` installed upstream (ping used by app status checks per plan; not verified in code).
