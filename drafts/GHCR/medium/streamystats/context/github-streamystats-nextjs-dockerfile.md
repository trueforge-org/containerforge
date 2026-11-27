# GitHub: fredrikburmester/streamystats apps/nextjs-app/Dockerfile (commit 4049ac60)

Source URL(s): https://raw.githubusercontent.com/fredrikburmester/streamystats/4049ac60351575c68639fcf8db76a4f477df8ab2/apps/nextjs-app/Dockerfile (fetched 2026-11-27)

## Build
- Stage deps `oven/bun:1.4.2-alpine`: apk `libc6-compat python3 make g++ vips-dev`; copies workspace package.json files; `bun install --frozen-lockfile` (cache mount /root/.bun).
- Stage database-builder: copies packages/database; `bun run build`.
- Stage nextjs-builder: copies apps/nextjs-app; ARG VERSION=latest, COMMIT_SHA, BUILD_TIME -> ENV NEXT_PUBLIC_VERSION / NEXT_PUBLIC_COMMIT_SHA / NEXT_PUBLIC_BUILD_TIME; NODE_ENV=production; NEXT_TELEMETRY_DISABLED=1; `bun --bun next build --experimental-build-mode compile`.

## Runtime (stage runner, node:26-alpine)
- apk `libc6-compat vips curl`.
- addgroup system gid 1001 `nodejs`; adduser system uid 1001 `nextjs`.
- ENV NODE_ENV=production, NEXT_TELEMETRY_DISABLED=1, HOSTNAME=0.0.0.0, PORT=3000.
- Copies `.next/standalone` to /app; `.next/static` and `public` to apps/nextjs-app/.
- USER nextjs. EXPOSE 3000.
- HEALTHCHECK 30s/10s/40s/3: `curl -f http://127.0.0.1:3000/api/health`.
- WORKDIR /app/apps/nextjs-app; CMD `["node","server.js"]`.
- LABEL org.opencontainers.image.source=https://github.com/fredrikburmester/streamystats

## User/UID
- nextjs uid 1001 / group nodejs gid 1001.

