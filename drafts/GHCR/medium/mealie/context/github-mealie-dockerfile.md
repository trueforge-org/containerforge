# mealie-recipes/mealie docker/Dockerfile (tag v3.31.0)

Source URL(s) + date:
- https://raw.githubusercontent.com/mealie-recipes/mealie/v3.31.0/docker/Dockerfile (2026-11-27; saved, read in full)

## What it is
Multi-stage build: Node frontend, Python 3.14 backend wheel, venv, production image.

## Build stages
| stage | base | what |
| --- | --- | --- |
| frontend-builder | node:26@sha256:438603bb... | `npm i -g pnpm@12.18.0`; COPY frontend; COPY mealie/repos/seed/resources/units/locales; `pnpm clean-install`; `pnpm generate` |
| python-base | python:3.14-slim@sha256:a2b82f3c... | ENV MEALIE_HOME=/app, VENV_PATH=/opt/mealie, PATH prepended; `useradd -u 911 -U -d /app -s /bin/bash abc`; `usermod -G users abc`; mkdir /app |
| backend-builder | python-base | apt curl; `pip install uv==0.13.7`; ENV UV_FROZEN=1; COPY uv.lock pyproject.toml mealie; frontend dist -> mealie/frontend; `uv build --out-dir dist`; `uv export --no-dev --extra pgsql` -> dist/dependencies.txt and dist/requirements.txt (with hashes) |
| packages | scratch | COPY dist |
| venv-builder-base | python-base | apt build-essential libpq-dev libwebp-dev ffmpeg libsasl2-dev libldap2-dev libssl-dev gnupg*; `python3 -m venv --upgrade-deps $VENV_PATH` |
| venv-builder | venv-builder-base | `pip install --require-hashes -r dependencies.txt`, then mealie wheel from requirements.txt |
| production | python-base | ENV PRODUCTION=true, TESTING=false, GIT_COMMIT_HASH from ARG COMMIT |

## Production stage
- apt: curl ffmpeg gosu iproute2 libldap-common libldap2 unzip
- `mkdir -p /run/secrets`
- COPY venv from venv-builder to $VENV_PATH
- NLTK: ENV NLTK_DATA=/nltk_data/; runs `$MEALIE_HOME/setup_nltk_data.sh` (from docker/setup_nltk_data.sh, not fetched)
- VOLUME `/app/data/`
- ENV APP_PORT=9000; EXPOSE ${APP_PORT}
- HEALTHCHECK CMD `/app/healthcheck.sh` (from docker/healthcheck.sh, not fetched)
- ENV HOST=0.0.0.0
- COPY docker/entry.sh -> /app/run.sh; ENTRYPOINT ["/app/run.sh"]
- No USER line in the production stage shown; `abc` (uid 911) created in base. Whether run.sh drops privileges (gosu is installed) was not verified.

## Runtime
- Entrypoint: `/app/run.sh` (content not fetched)
- Python venv at /opt/mealie on PATH; console script `mealie = mealie.main:main`.

## Env vars (Dockerfile)
| var | value |
| --- | --- |
| MEALIE_HOME | /app |
| VENV_PATH | /opt/mealie |
| PYTHONUNBUFFERED | 1 |
| PYTHONDONTWRITEBYTECODE | 1 |
| PRODUCTION | true |
| TESTING | false |
| NLTK_DATA | /nltk_data/ |
| APP_PORT | 9000 |
| HOST | 0.0.0.0 |

## Ports
- 9000 (APP_PORT)

## Volumes/paths
- /app/data/ (VOLUME)
- /nltk_data/ (NLTK_DATA)
- /run/secrets (created)

## Healthcheck
- `/app/healthcheck.sh` (default interval/timeout)

## Version/asset naming
- Wheel `dist/mealie-${MEALIE_VERSION}-py3-none-any.whl` and sdist `mealie-${MEALIE_VERSION}.tar.gz`, version from pyproject.toml.
- Renovate annotations present for node/python digests, pnpm, uv.

## Gotchas
- Python 3.14 required (pyproject `requires-python >=3.14,<3.15`).
- Build uses `uv export --no-dev --extra pgsql` with hashed requirements (`--require-hashes`).
- Needs ffmpeg and LDAP libs in the runtime image.
