# GitHub: JVT038/MetaTube Dockerfile @ 879a385

Source URL(s): https://raw.githubusercontent.com/JVT038/MetaTube/879a385/Dockerfile (fetched 2026-11-26)

## Base / stages
- Single stage: `FROM python:3.12-alpine`
- LABEL Author/Maintainer JVT038, Name MetaTube

## Env
- `PORT=5000`
- `FFMPEG=/usr/bin`
- `DOWNLOADS=/downloads`
- `DATABASE_URL=sqlite:////database/app.db`

## Install steps (single RUN)
- apk update
- apk add --no-cache --upgrade alpine-sdk libffi-dev ffmpeg libmagic
- mkdir -p {/config,$DOWNLOADS,/database}  (brace expansion; not expanded by busybox sh, may create one literal dir; reported by fetch summary, unverified)
- pip install --upgrade pip; pip install -r /config/requirements.txt
- apk del --purge alpine-sdk

## Copy / entry
- `COPY . /config/`
- `EXPOSE $PORT` (5000)
- `ENTRYPOINT ["/usr/local/bin/python3", "config/metatube.py"]` (relative path)
- No ARG, USER, VOLUME, WORKDIR, CMD, HEALTHCHECK. No uid/gid set (runs as root).

## Paths
- /config (app), /downloads, /database/app.db, /usr/bin (ffmpeg)

## Gotchas
- Root user, no USER instruction.
- Brace-expansion mkdir line (see above).
