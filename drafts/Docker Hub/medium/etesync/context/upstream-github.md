# etesync/server (upstream) and victor-rds/docker-etebase (third-party image source)

## Source URL(s) + date
- https://raw.githubusercontent.com/victor-rds/docker-etebase/c06eb631/tags/base/Dockerfile (fetched 2026-11-26)
- https://raw.githubusercontent.com/etesync/server/master/README.md (fetched 2026-11-26; master, not tag v0.14.2)
- https://api.github.com/repos/etesync/server/releases/latest: 404 (no GitHub releases; tags only)
- https://hub.docker.com/v2/repositories/victorrds/etesync/tags/latest (fetched)

## What it is
EteSync server (Etebase backend): Django + FastAPI (ASGI) server for end-to-end encrypted sync. The upstream repo ships no Docker image; victor-rds/docker-etebase is a third-party image build.

## Install/build steps (victor-rds Dockerfile, base tag)
- `FROM python:3.12.4`
- ARGs: `DEFAULT_UID=373`, `DEFAULT_GID=373`, `ETE_VERSION=master`, `ETE_REPO=https://github.com/etesync/server.git`
- ENV: `BASE_DIR=/etebase`, `DATA_DIR=/data`, `MEDIA_ROOT=/data/media`, `ETEBASE_EASY_CONFIG_PATH=/data/etebase-server.ini`, `SECRET_FILE=/data/secret.txt`, `STATIC_ROOT=/srv/etebase/static`, `SERVER=http`, `PORT=3735`
- apt (build deps `libldap2-dev libsasl2-dev`): `mime-support libffi8 libpq5 libssl3 libldap-common libsasl2-2`; build deps purged afterwards.
- `git clone --depth=1 --branch=${ETE_VERSION} ${ETE_REPO} ${BASE_DIR}`; `rm -r .git`
- `pip install --no-cache-dir -r requirements.txt psycopg2-binary python-ldap`
- User: `addgroup --system --gid 373 etebase`; `adduser --system --no-create-home --uid 373 --ingroup etebase etebase`, home `/etebase`
- `mkdir -p /data/media /srv/etebase/static`; `DJANGO_STATIC_ROOT=/srv/etebase/static manage.py collectstatic --no-input`; `rm /etebase/secret.txt`
- `COPY --chown=373:373 context /`; `USER etebase:etebase`
- `EXPOSE ${PORT}` (3735); `VOLUME /data`; `ENTRYPOINT ["/entrypoint.sh"]` (entrypoint script in `context/` of that repo, NOT fetched)

## Runtime deps
- Python 3.12 (upstream image). apt runtime: mime-support, libffi8, libpq5, libssl3, libldap-common, libsasl2-2.
- Python packages: requirements.txt of etesync/server (Django, FastAPI, msgpack, pynacl, uvicorn, etc., compiled for py3.12 per plan), plus psycopg2-binary and python-ldap.

## Entrypoint/flags
- Upstream README (master): run with `uvicorn etebase_server.asgi:application --host 0.0.0.0 --port 8000`.
- victor-rds: `ENTRYPOINT ["/entrypoint.sh"]` (script not fetched).

## Env vars (upstream README + victor-rds ENV)
| Var | Value/default | Notes |
| --- | --- | --- |
| ETEBASE_EASY_CONFIG_PATH | `/data/etebase-server.ini` (victor-rds) | config file path (per plan, settings read it) |
| DJANGO_STATIC_ROOT | `/srv/etebase/static` | collectstatic target |
| DJANGO_MEDIA_ROOT | `/data/media` | media dir (victor-rds uses MEDIA_ROOT env) |
| SERVER | http | victor-rds ENV (entrypoint use not verified) |
| PORT | 3735 | victor-rds ENV |
| SECRET_KEY | n/a | README: ephemeral secret; `secret.txt` auto-created if missing |

Upstream README also refers to `ALLOWED_HOSTS` in config (settings key, see settings section of the ini).

## Ports
- victor-rds: 3735 (`PORT`). Upstream README run command: 8000. Plan chose 8000.

## Volumes/paths
- `/data` (`VOLUME /data` in victor-rds). Subpaths: `media/`, `etebase-server.ini`, `secret.txt`.
- Static: `/srv/etebase/static`.

## User/UID
- victor-rds: UID/GID 373 (`etebase`), `USER etebase:etebase`.

## Config files
- `etebase-server.ini` (path via `ETEBASE_EASY_CONFIG_PATH`): sections per plan (`[global]`, `[allowed_hosts]`, `[database]`).
- `secret.txt` (SECRET_KEY file). Upstream README: delete it to revoke the key.

## Healthcheck
- None in victor-rds Dockerfile. Upstream endpoint `GET /api/v1/authentication/is_etebase/` (per plan, not re-verified here).

## Version/asset naming
- GitHub: tags only (releases/latest 404). Tags per plan: v0.13.0 to v0.14.2.
- victor-rds: `ETE_VERSION` ARG, default `master`. Hub `victorrds/etesync` last pushed 2024-06-15 (amd64, arm64, unknown/attestation).

## Arch
- amd64, arm64 on Docker Hub (victor-rds image).

## Gotchas
- `secret.txt` is created by settings load at build (collectstatic); must be removed after build (victor-rds does `rm`).
- README: ALLOWED_HOSTS and SECRET_KEY settings must be configured for production.
- Upstream README does not mention Docker (grep of master README found no Docker section).

## Licence
- AGPL-3.0 (per plan; LICENSE not fetched here).
