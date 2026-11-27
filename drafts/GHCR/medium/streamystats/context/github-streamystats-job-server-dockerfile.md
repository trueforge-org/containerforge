# GitHub: fredrikburmester/streamystats apps/job-server/Dockerfile (commit 4049ac60)

Source URL(s): https://raw.githubusercontent.com/fredrikburmester/streamystats/4049ac60351575c68639fcf8db76a4f477df8ab2/apps/job-server/Dockerfile (fetched 2026-11-27)

## Build (stage builder, oven/bun:1.4.2)
- WORKDIR /app; COPY package.json bun.lock, packages/database/package.json, apps/job-server/package.json, apps/nextjs-app/package.json.
- `bun install --frozen-lockfile`; COPY packages/database and apps/job-server.
- packages/database: `bun run build`; `bun build ./src/migrate-entrypoint.ts --compile --minify --outfile migrate-bin`.
- apps/job-server: `bun add geoip-lite@2.0.3`; `bun build ./src/index.ts --compile --minify --outfile server`.

## Runtime (stage runner, debian:bookworm-20260824-slim)
- apt install curl ca-certificates.
- WORKDIR /app; copies `migrate-bin`, `drizzle/`, `server`, and geoip-lite data into `node_modules/.bun/geoip-lite@2.0.3/node_modules/geoip-lite/data`.
- ENV NODE_ENV=production, PORT=3005, HOST=0.0.0.0.
- LABEL org.opencontainers.image.source=https://github.com/fredrikburmester/streamystats
- EXPOSE 3005.
- HEALTHCHECK every 30s, timeout 10s, start-period 40s, retries 3: `curl -f http://127.0.0.1:3005/health`.
- CMD `["sh","-c","./migrate-bin && exec ./server"]` (migrations run before server).

## Runtime deps
- Compiled bun binaries; glibc (Debian). No node runtime needed.

## User/UID
- No USER directive (runs as root).

## Gotchas
- Migrations run at every container start (migrate-bin expects ./drizzle relative to CWD = /app).
