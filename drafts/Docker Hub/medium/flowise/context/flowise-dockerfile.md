# FlowiseAI/Flowise (docker/Dockerfile + repo)

Source URL(s): https://github.com/FlowiseAI/Flowise/blob/a65f81bb43ef66d3ce734bf0dff4223ae8041c95/docker/Dockerfile (raw fetched: https://raw.githubusercontent.com/FlowiseAI/Flowise/a65f81bb43ef66d3ce734bf0dff4223ae8041c95/docker/Dockerfile) ; https://github.com/FlowiseAI/Flowise
Date: fetched 2026-11-26

## What it is
- Low-code platform for LLM apps / AI agents (Assistant, Chatflow, Agentflow builders). npm package `flowise`.

## Build (docker/Dockerfile @ a65f81b)
- Global ARG `NODE_VERSION=24` (CI overridable).
- Stage build: `FROM node:${NODE_VERSION}-alpine AS build`, USER root; `apk add --no-cache git python3 py3-pip make g++ build-base cairo-dev pango-dev`; `ENV PUPPETEER_SKIP_DOWNLOAD=true`; `RUN npm install -g flowise` (version pinnable).
- Stage runtime: `FROM node:${NODE_VERSION}-alpine`; `apk add --no-cache chromium git python3 py3-pip make g++ build-base cairo-dev pango-dev curl`; `ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser`; COPY `/usr/local/lib/node_modules` and `/usr/local/bin` from build; `chown -R node:node` on those.
- `USER node`; `ENTRYPOINT ["flowise", "start"]`.
- No WORKDIR, EXPOSE, VOLUME, CMD, HEALTHCHECK.

## Runtime deps
- Node 24 (alpine, musl), chromium (Puppeteer), cairo/pango, git, python3.
- Database: SQLite default; postgres/mysql optional.

## Entrypoint/flags
- `flowise start` (ENTRYPOINT). Credentials via env or flags: `npx flowise start --FLOWISE_USERNAME=user --FLOWISE_PASSWORD=1234`.

## Env vars (Dockerfile)
| Var | Value |
| --- | --- |
| PUPPETEER_SKIP_DOWNLOAD | true (build stage) |
| PUPPETEER_EXECUTABLE_PATH | /usr/bin/chromium-browser (runtime) |

Runtime env: see flowise-docs-env-vars.md (PORT, DATABASE_*, SECRETKEY_PATH, LOG_PATH, BLOB_STORAGE_PATH, STORAGE_TYPE, DEBUG).

## Ports
- 3000/tcp (PORT default 3000; docker run example `-p 3000:3000`; no EXPOSE in Dockerfile).

## Volumes/paths
- Defaults (docs): DATABASE_PATH `~/.flowise`, SECRETKEY_PATH `Flowise/packages/server`, LOG_PATH `Flowise/packages/server/logs`, BLOB_STORAGE_PATH `~/.flowise/storage`.

## User/UID
- `node` (UID 1000 in node images).

## Config files
- None in image; config via env.

## Healthcheck
- None.

## Version/asset naming
- npm package `flowise`; upstream GitHub release tag `flowise@3.1.4`, no assets.

## Arch
- Docker Hub: amd64, arm64.

## Gotchas
- `npm install -g flowise` installs latest unless version pinned.
- Build deps (build-base, cairo-dev) are also installed in the final image.
