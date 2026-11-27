# GitHub: pgadmin-org/pgadmin4 (Dockerfile at REL-9_19)

## Source URL(s) + date
- https://raw.githubusercontent.com/pgadmin-org/pgadmin4/REL-9_19/Dockerfile
- Fetched 2026-11-27
- Licence: PostgreSQL Licence (Copyright 2013-2026 pgAdmin Development Team).

## Stages (upstream Dockerfile)
| Stage | Base | Purpose |
| --- | --- | --- |
| app-builder | alpine:latest | Node/yarn JS bundle of `/pgadmin4/web` |
| env-builder | python:3-alpine | `/venv` from requirements.txt, pruned |
| docs-builder | env-builder | sphinx HTML docs |
| pg13..pg18-builder | postgres:13..18-alpine | pg_dump/psql binaries |
| tool-builder | alpine:latest | pg tools layout |
| final | python:3-alpine | runtime |

## Install/build steps (key RUN lines)
- app-builder: `apk add` autoconf automake bash g++ git libc6-compat libjpeg-turbo-dev libpng-dev libtool make nasm nodejs npm yarn zlib-dev; `corepack enable`; `yarn install --immutable`; `yarn run bundle`.
- env-builder: `python3 -m venv --system-site-packages --without-pip /venv`; `pip install -r requirements.txt`; `prune_site_packages.py`.
- final: apk add bash postfix krb5-libs libcurl libjpeg-turbo shadow sudo tzdata libedit libldap libcap su-exec; `pip install gunicorn==23.0.0`.
- final creates user `pgadmin` UID 5050 GID root, `/run/pgadmin` and `/var/lib/pgadmin` (chmod g=u), `config_distro.py`, `setcap CAP_NET_BIND_SERVICE` on a copy of python3, sudoers entries for postfix.

## Runtime deps
- Python 3 venv, gunicorn 23.0.0, postfix, sudo, libpq (symlinked as libpq.so.5), libcurl, libldap, krb5.

## Entrypoint/flags
- `ENTRYPOINT ["/entrypoint.sh"]`, no CMD.
- Copied: `pkg/docker/entrypoint.sh` to `/entrypoint.sh`; `pkg/docker/run_pgadmin.py`, `pkg/docker/gunicorn_config.py` to `/pgadmin4/` (contents not fetched).

## Env vars
- `PYTHONPATH=/pgadmin4`.
- Admin login vars (`PGADMIN_DEFAULT_EMAIL`, `PGADMIN_DEFAULT_PASSWORD`) not in the Dockerfile; they are read by entrypoint/config (not fetched).

## Ports
- `EXPOSE 80 443`.

## Volumes/paths
- `VOLUME /var/lib/pgadmin`; `WORKDIR /pgadmin4`; app at `/pgadmin4`; venv at `/venv`; pg tools at `/usr/local/pgsql/pgsql-NN/`.

## User/UID
- `USER 5050` (pgadmin).

## Arch
- Python app; upstream images published for amd64 and arm64.

## Gotchas
- Runs as UID 5050 with `chmod g=u` on writable dirs.
- Dockerfile uses `alpine:latest`, `python:3-alpine` (floating tags).
- `chmod g=u /etc/passwd` (group-writable passwd).
