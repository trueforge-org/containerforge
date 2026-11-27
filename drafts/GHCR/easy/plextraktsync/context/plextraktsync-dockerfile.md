# Taxel PlexTraktSync Dockerfile (commit 5f951838)

## Source URL(s) + date
- https://raw.githubusercontent.com/Taxel/PlexTraktSync/5f951838eaea4466d078571cc548ac51d5ed2341/Dockerfile (fetched 2026-11-27)
- Blob URL from list points to same commit (not fetched separately)

## Build args / base
- `# syntax = docker/dockerfile:1.3-labs`
- `ARG PYTHON_VERSION=3.13`, `ARG ALPINE_VERSION=3.21`
- Base: `python:$PYTHON_VERSION-alpine$ALPINE_VERSION`; env PIP_DISABLE_PIP_VERSION_CHECK=1, PIP_ROOT_USER_ACTION=ignore; WORKDIR /app

## Stages
| Stage | Purpose |
| --- | --- |
| tools | apk add util-linux shadow; copy /usr/bin/setpriv, usermod, groupmod and libs libcap-ng.so.0, libbsd.so.0, libmd.so.0 into /dist |
| wheels | pip download -r requirements.txt into /wheels (pip cache mount); build any sdist/zip into wheels |
| build | apk add git; pip install pipenv; `pipenv run pip install /wheels/*.whl`; path /root/.local/share/virtualenvs/app-*/lib/python$PYTHON_VERSION/site-packages |
| compile | COPY plextraktsync/ and plextraktsync.sh; writes `__version__` from APP_VERSION into plextraktsync/__init__.py; compileall; chmod a+rX,g-w |
| runtime | ENTRYPOINT ["/init"]; env, VOLUME, user creation, copy stages, `entrypoint.sh` -> /init, `ln -s /app/plextraktsync.sh /usr/bin/plextraktsync`, `chmod a+x /root` |
| test | runtime + TRACE=1 + `RUN ["/init", "test"]` (self-test) |
| default | runtime |

## Runtime env
| Name | Value |
| --- | --- |
| XDG_CACHE_HOME | /app/xdg/cache |
| XDG_CONFIG_HOME | /app/xdg/config |
| XDG_DATA_HOME | /app/xdg/data |
| PIPX_BIN_DIR | /app/xdg/bin |
| PIPX_HOME | /app/xdg/pipx |
| PYTHONUSERBASE | /app/xdg |
| HOME | /app/xdg |
| PATH | /app/xdg/bin:/app/xdg/.local/bin:/root/.local/bin:$PATH |
| PTS_CONFIG_DIR | /app/config |
| PTS_CACHE_DIR | /app/config |
| PTS_LOG_DIR | /app/config |
| PTS_IN_DOCKER | 1 |
| PYTHONUNBUFFERED | 1 |

## User/UID
- Group `plextraktsync` gid 1000 (system); user `plextraktsync` uid 1000, no password, home = WORKDIR (`--home "$(pwd)"`), no-create-home
- No USER directive in Dockerfile. Entrypoint runs as root unless PUID/PGID are set (see `plextraktsync-entrypoint.md`)

## Volumes
- `VOLUME /app/config`, `VOLUME $HOME` (/app/xdg)

## Ports / Healthcheck
- None in Dockerfile

## Gotchas
- `chmod a+x /root` needed for the copied site-packages under /root (comment cites CPython issue 69667)
- Requires `APP_VERSION` build arg for version string; defaults to "unknown"
