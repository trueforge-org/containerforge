# Dispatcharr Dockerfile

Source URL: https://raw.githubusercontent.com/Dispatcharr/Dispatcharr/83f82bf388b72ec1e6cc356f1015a9812228b424/docker/Dockerfile (commit 83f82bf, fetched 2026-11-27; same content as the blob URL in urls.txt)

## What it is
Application image. Builds the React frontend in a node stage, then layers the app onto a configurable base image.

## Build args
- REPO_OWNER=dispatcharr, REPO_NAME=dispatcharr, BASE_TAG=base (redeclared for final stage)
- TIMESTAMP (optional; writes `__timestamp__` in /app/version.py via sed)

## Stages
1. `FROM node:24 AS frontend-builder`: WORKDIR /app/frontend; COPY ./frontend; `rm -rf node_modules || true; npm install --no-audit --progress=false`; `npm run build && rm -rf node_modules .cache`
2. `FROM ghcr.io/${REPO_OWNER}/${REPO_NAME}:${BASE_TAG} AS final`
   - ENV VIRTUAL_ENV=/dispatcharrpy; PATH="$VIRTUAL_ENV/bin:$PATH"
   - WORKDIR /app; `COPY . /app`
   - `COPY ./docker/nginx.conf /etc/nginx/sites-enabled/default`
   - For each `/app/docker/entrypoint*.sh`: strip CRLF, chmod +x
   - `rm -rf /app/frontend`; `COPY --from=frontend-builder /app/frontend/dist /app/frontend/dist`
   - Timestamp sed on /app/version.py if TIMESTAMP set
   - `ENTRYPOINT ["/app/docker/entrypoint.sh"]`

## Base
- Final image base is `ghcr.io/dispatcharr/dispatcharr:${BASE_TAG}` (default `base`). The base image contains the Python venv at /dispatcharrpy and nginx config path (not fetched here). The app's own image is built on top of it.

## Ports / user / volumes
- No EXPOSE, no USER, no VOLUME in this Dockerfile. Port 9191 comes from nginx config and docs (see dispatcharr-readme.md, dispatcharr-compose-aio.md).

## Gotchas
- Build depends on a prebuilt base image tag; the base's own Dockerfile is not in this summary.
- Frontend uses node 24.
