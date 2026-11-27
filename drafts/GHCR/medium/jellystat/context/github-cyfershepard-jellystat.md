# Upstream repo: CyferShepard/Jellystat (tag 1.1.12, commit e0a38eeeff4c4bbaba60abad5f76e8a54415d1a8)

Source URL(s) + date: https://raw.githubusercontent.com/CyferShepard/Jellystat/e0a38eeeff4c4bbaba60abad5f76e8a54415d1a8/{Dockerfile,entry.sh,docker-compose.yml,package.json} (fetched 2026-11-27)

## What it is
- Statistics app for Jellyfin. package.json name `jfstat`, version `1.1.12`.
- Client: Vite (`vite build`). Server: `backend/server.js` (Node).

## Install/build steps (upstream Dockerfile)
- Stage 1 `FROM node:26-bookworm-slim AS builder`: `WORKDIR /app`, `COPY package*.json`, `npm cache clean --force`, `npm install`, `COPY ./ ./`, `COPY entry.sh ./`, `npm run build`.
- Stage 2 `FROM node:26-bookworm-slim`: apt-get upgrade, install `wget`, autoremove, clean lists. `WORKDIR /app`, `COPY --from=builder /app .`, `COPY --chmod=755 entry.sh /entry.sh`.

## Runtime deps
- Node (base image node:26), wget (healthcheck only).
- npm scripts: `start` = `cd backend && node server.js`; `build` = `vite build`.

## Entrypoint/flags
- `CMD ["/entry.sh"]`.
- entry.sh: loops over env vars named `FILE__<NAME>`; if the value is a readable file, exports `<NAME>=$(cat file)`, else prints "Error: Secret file ... does not exist" and exits 1. Warns if `<NAME>` was already set. Then runs `npm run start`.

## Env vars (upstream docker-compose.yml, Jellystat service)
| Var | Example | Note |
| --- | --- | --- |
| POSTGRES_USER | postgres | |
| POSTGRES_PASSWORD | mypassword | |
| POSTGRES_IP | jellystat-db | |
| POSTGRES_PORT | 5432 | |
| JWT_SECRET | (commented "please set this to a random string") | |
| TZ | mytimezone | |
| FILE__<NAME> | - | secret loader (entry.sh) |

## Ports
- `EXPOSE 3000`; compose maps `3000:3000`.

## Volumes/paths
- Compose volume `jellystat-backup-data:/app/backend/backup-data`.
- App root `/app` (WORKDIR, copied from builder).

## User/UID
- No `USER` in Dockerfile: runs as root.

## Config files
- None in image. Config via env.

## Healthcheck
- Dockerfile HEALTHCHECK: interval 30s, timeout 5s, start-period 10s, retries 3, `wget --no-verbose --tries=1 --spider http://localhost:3000/auth/isconfigured`.
- Compose healthcheck: `http://localhost:3000/auth/isConfigured` (capital C), interval 60s, timeout 30s, retries 5, start_period 30s.

## Version/asset naming
- Git tag `1.1.12`; no release assets (source build). Compose db: `postgres:18.1`.

## Arch
- Not stated upstream (node base image is multi-arch).

## Gotchas
- Dockerfile HEALTHCHECK path `/auth/isconfigured` vs compose `/auth/isConfigured` (case differs).
- Compose uses `cyfershepard/jellystat:latest`, not the GHCR image.
- entry.sh uses `cut -d= -f2` for values, so secret paths containing `=` break.
- `package.json` `start-app` script also exists (`cd backend && node server.js`).
