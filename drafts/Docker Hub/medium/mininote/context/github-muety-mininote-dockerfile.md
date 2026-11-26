# GitHub: muety/mininote Dockerfile (master)

Source URL(s): https://raw.githubusercontent.com/muety/mininote/master/Dockerfile (fetched 2026-11-26)

## Base / stages
- Single stage: `FROM node:22-alpine`
- MAINTAINER line present (author name/email; not recorded)

## Build / steps (in order)
- `WORKDIR /app`
- `ARG base_url=/`; `ENV BASE_URL $base_url`
- `COPY . /app/`
- `VOLUME ["/app/data"]`
- RUN: `cd /app && corepack enable && yarn set version stable && yarn`
- RUN: `cd /app/webapp && corepack enable && yarn set version stable && yarn && yarn build:base && cd ..`
- `ENTRYPOINT yarn start` (shell form)

## Runtime
- No USER: runs as root. No uid/gid set.
- No EXPOSE, CMD, HEALTHCHECK.
- Port 3000 (from README Docker example).

## Paths
- /app (workdir), /app/data (volume), /app/webapp (frontend build)

## Config (env, from README)
- HTTPS_CERT: path to TLS cert; HTTPS_KEY: path to key. No defaults documented.
- TLS mandatory for hosts other than localhost (window.crypto.subtle requires it), since v1.0.0.

## Gotchas
- Node 22.12.0 LTS or newer required (README).
- Persistent state is /app/data only; no DB option documented.
