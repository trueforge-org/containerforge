# djedi/DailyNotes (upstream, GitHub)

## Source URL(s) + date
- https://raw.githubusercontent.com/djedi/DailyNotes/9d1a3a7ea3597d93b2c8c4600437318a59eaa028/Dockerfile (fetched 2026-11-26)
- https://raw.githubusercontent.com/djedi/DailyNotes/9d1a3a7ea3597d93b2c8c4600437318a59eaa028/README.md
- https://raw.githubusercontent.com/djedi/DailyNotes/9d1a3a7ea3597d93b2c8c4600437318a59eaa028/run.sh
- https://raw.githubusercontent.com/djedi/DailyNotes/9d1a3a7ea3597d93b2c8c4600437318a59eaa028/LICENSE
- https://raw.githubusercontent.com/djedi/DailyNotes/HEAD/requirements.txt (HEAD, not the pinned commit)
- https://raw.githubusercontent.com/djedi/DailyNotes/9d1a3a7ea3597d93b2c8c4600437318a59eaa028/verify_env.py
- https://api.github.com/repos/djedi/DailyNotes/releases/latest: not fetched (plan lists release 2026.10.29-00)

## What it is
Self-hosted Markdown daily notes/tasks app. Quart (async) Python backend with alembic/SQLAlchemy, Vue client built with npm. README: "Current version: 1.0.0-beta.22".

## Install/build steps (upstream Dockerfile)
- Stage 1 `FROM nikolaik/python-nodejs:python3.10-nodejs24 AS builder`
  - apt: `build-essential libffi-dev`
  - `COPY . .`, `pip install --no-cache-dir -r requirements.txt`
  - `cd client && npm install --prefer-offline --no-audit --legacy-peer-deps`
  - `cd client && npm run build` -> `/app/dist/`
- Stage 2 `FROM python:3.10-slim`
  - apt: `libffi-dev`, later `curl`
  - Copies `/usr/local/lib/python3.10/site-packages`, `/usr/local/bin` from builder
  - Copies `server.py config.py requirements.txt run.sh verify_env.py verify_data_migrations.py app/ migrations/ dist/`
  - `chmod +x run.sh verify_env.py verify_data_migrations.py`; `mkdir -p /app/config`
- `EXPOSE 8000`
- `HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 CMD curl -f http://localhost:8000/health || exit 1`
- `ENTRYPOINT ["./run.sh"]` (no CMD)

## Runtime deps
- Python 3.10 (upstream), `libffi-dev`, `curl`. Python packages from requirements.txt (see below).
- requirements.txt pins: quart==0.20.0, quart-cors==0.7.0, alembic==1.14.0, sqlalchemy[asyncio]==2.0.36, aiosqlite==0.20.0, uvicorn[standard]==0.34.0, pyjwt==2.15.0, argon2-cffi==23.1.0, python-frontmatter==1.1.0, pycryptodome==3.23.0, httpx==0.28.1, requests==2.33.0, python-dateutil==2.9.0.post0, aiosmtplib==5.1.2, black==26.10.1, pre-commit==4.5.0, psycopg2-binary==2.9.10, asyncpg==0.30.0, pymysql==1.1.1 (DB drivers optional).

## Entrypoint/flags
- `run.sh` (sh):
  1. If `./config/.env` exists, source it.
  2. `./verify_env.py`
  3. Source `./config/.env` again if present.
  4. `export FLASK_APP=server.py`
  5. `flask db upgrade`
  6. `./verify_data_migrations.py`
  7. `exec gunicorn server:app -b 0.0.0.0:8000`
- GOTCHA: `flask` CLI and `gunicorn` are not in requirements.txt (checked whole file; only Quart, uvicorn). Installing them is needed for run.sh to work, or the script fails.

## Env vars (README)
| Var | Default | Notes |
| --- | --- | --- |
| API_SECRET_KEY | auto-generated if unset | signs API tokens (verify_env.py reads it) |
| DATABASE_URI | SQLite if unset | e.g. `sqlite:////app/config/app.db`, postgresql://, mysql:// |
| DB_ENCRYPTION_KEY | auto-generated if unset | data-at-rest key; length multiple of 16; changing it makes data unreadable |
| PREVENT_SIGNUPS | False | any value disables signup |
| BASE_URL | None | reverse proxy subfolder |
| PUID | None | user ID for folder permissions |
| PGID | None | group ID for folder permissions |
| DEFAULT_TIMEZONE | None | e.g. `America/Denver`; falls back to server local time |

Note: verify_env.py reads `API_SECRET_KEY`, `DATABASE_URI`, `DB_ENCRYPTION_KEY` via os.getenv. run.sh does not read PUID/PGID (no chown in run.sh or verify_env.py).

## Ports
- 8000 (gunicorn bind `0.0.0.0:8000`, EXPOSE 8000). README: "default port is now 8000".

## Volumes/paths
- `/app/config`: DB (`app.db` default) and `.env`. Upstream README volume: `/app/config`.
- `/app/dist`: built frontend (static). `/app/migrations`, `/app/app`.

## User/UID
- Upstream: not set (root). PUID/PGID README-only, not applied in run.sh.

## Config files
- `/app/config/.env` (optional, sourced by run.sh if present).

## Healthcheck
- `curl -f http://localhost:8000/health` (Dockerfile). README compose example uses `curl -f http://localhost:8000/` instead.

## Version/asset naming
- README: "Current version: 1.0.0-beta.22" (README text; differs from release tag naming).
- Plan (not fetched here) says latest release `2026.10.29-00`. Not verified.
- Docker Hub `m0ngr31/dailynotes:latest` (tag API): one amd64 image, digest sha256:d2a9e353de7db428e73f1b918a820b85b54f3634b3a5a6f3afa009bae81c854e, last pushed 2025-12-11T04:55:10Z.

## Arch
- amd64 listed on Docker Hub tag. Not stated in repo.

## Gotchas
- Builder uses `nikolaik/python-nodejs:python3.10-nodejs24`; `npm install --legacy-peer-deps` with lock regeneration (Dockerfile comment).
- Runtime copies only the Python install dir `/usr/local/lib/python3.10/site-packages` and `/usr/local/bin`. Builder path is python3.10.
- Frontend assets in `/app/dist`.
- Upstream says `DB_ENCRYPTION_KEY` change makes data undecryptable.

## License
- MIT (LICENSE raw fetched: "The MIT License (MIT)").
