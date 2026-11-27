# github FoxxMD/multi-scrobbler Dockerfile (pinned d164f568)

Source URL(s): https://raw.githubusercontent.com/FoxxMD/multi-scrobbler/d164f568a47874e7a8d33604db630e6edbfdcca6/Dockerfile (fetched 2026-11-27)

## Stages
- `builder`: `FROM node:24-trixie-slim@sha256:af02d57b...` ; `npm install -g concurrently`; `mkdir /config`
- `app-src`: from builder; copies package*.json, tsconfig, patches, docsite pkg files; `npm run install:parallel`; `COPY . /app`
- `test`: `npm run test:parallel` (CI with --target test)
- `app-build`: `ENV NODE_ENV=production`; ARG BASE_URL (docs subpath); ARG DOCS_CHANGELOGS=false; `npm run build:parallel`; removes node_modules
- `app-deps`: `npm ci --omit=dev`; removes drizzle-kit, typescript, youtubei.js bundle; `npx @usex/prune-mod -w`
- `app` (default target): `FROM gcr.io/distroless/nodejs24-debian13:nonroot@sha256:6abfcb36...` ; WORKDIR /app; copies /app/dist, /app/docsite/build, node_modules, src/backend, src/core, *.json *.js *.ts index.html
- `curl-dl`: static curl from stunnel/static-curl (CURL_VERSION, sha256 per arch: x86_64, aarch64 musl)
- `busybox`: distroless nodejs24 debug-nonroot
- `app-debug`: app + busybox + static curl (troubleshooting; `docker exec -it ... sh`)

## Runtime
- ENTRYPOINT: distroless default `/nodejs/bin/node` (extra node flags passed via CMD)
- runs as distroless nonroot user 65532:65532
- app files root-owned, read-only for running user
- /config owned by 65532:65532 so anonymous volumes are writable

## Env vars (Dockerfile)
| var | value |
| --- | --- |
| TZ | Etc/GMT |
| NODE_ENV | production |
| IS_DOCKER | true |
| COLORED_STD | true |
| PORT | 9078 (ARG webPort) |
| CONFIG_DIR | /config |
| LOGS_DIR | /config/logs |
| DATA_DIR | /config |
| APP_VERSION | from ARG APP_BUILD_VERSION |
| BASE_URL | build ARG, docs subpath |
| DOCS_CHANGELOGS | false (build ARG) |

## Ports
- 9078 (EXPOSE $PORT)

## Volumes
- VOLUME /config (data_dir ARG default /config)

## Labels
- org.opencontainers.image.version = APP_BUILD_VERSION; licenses MIT; source github FoxxMD/multi-scrobbler; documentation https://docs.multi-scrobbler.app

## Build args
- APP_BUILD_VERSION, BUILD_DATE (default 0), webPort (9078), data_dir (/config), BASE_URL, DOCS_CHANGELOGS

## Gotchas
- Native addons (sharp, classic-level): builder Node major and Debian release must match distroless runtime
- Bind-mounted config must be owned by UID:GID chosen via `user:` or chown to 65532:65532
- Pinned distroless/base image digests in Dockerfile
