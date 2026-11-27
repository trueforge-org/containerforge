# GitHub: krateng/maloja Containerfile @ v3.2.10

Source URL(s), fetched 2026-11-27:
- https://github.com/krateng/maloja/blob/v3.2.10/Containerfile
(Fetched via a converted view; content reproduced as instructions, not verbatim.)

## Base
- FROM `lsiobase/alpine:3.21 AS base` (single stage shown)
- WORKDIR `/usr/src/app`

## Build steps
1. COPY --chown=abc:abc requirements.txt to ./requirements.txt
2. Layer (one RUN):
   - `apk add --no-cache --virtual=build-deps gcc g++ python3-dev libxml2-dev libxslt-dev libffi-dev libc-dev py3-pip linux-headers`
   - `apk add --no-cache python3 py3-lxml libmagic tzdata`
   - `python3 -m venv /venv`; activate; `python3 -m ensurepip`
   - `pip install -U --no-cache-dir pip wheel`
   - `pip install --no-cache-dir -r requirements.txt`
   - `apk del --purge build-deps`; `rm -rf /tmp/* ${HOME}/.cache`
3. COPY --chown=abc:abc . .
4. Install layer (one RUN):
   - `apk add --no-cache --virtual=install-deps py3-pip`
   - `python3 -m venv /venv`; activate; `pip3 install /usr/src/app`
   - `apk del --purge install-deps`; `rm -rf /tmp/* ${HOME}/.cache`
5. COPY --chmod=755 container/root/ /  (s6 init scripts; contents not fetched)

## Runtime
- ENV MALOJA_SKIP_SETUP=yes MALOJA_CONTAINER=yes PYTHONUNBUFFERED=1
- ENV PUID=0 PGID=0
- EXPOSE 42010
- No USER, no ARG, no VOLUME, no ENTRYPOINT, no CMD, no HEALTHCHECK. Ownership via base `abc` user (lsiobase).

## Paths
- Requirements: /usr/src/app/requirements.txt
- App install: /usr/src/app (pip install of the project)
- Virtualenv: /venv
- Config/data path: not set in this file (MALOJA_DATA_DIRECTORY not defined here).

## Gotchas
- Runtime user is controlled by PUID/PGID (default 0 = root) via lsiobase init, not by USER.
- Python 3 runtime via Alpine py3 packages inside lsiobase/alpine:3.21.
