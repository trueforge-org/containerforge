# Mintplex-Labs/anything-llm (upstream Dockerfile, entrypoint, release)

Source URL(s) + date: https://raw.githubusercontent.com/Mintplex-Labs/anything-llm/eb498cf2c211/docker/Dockerfile ; .../docker/docker-entrypoint.sh ; release redirect https://github.com/Mintplex-Labs/anything-llm/releases/latest (fetched 2026-11-27)

## What it is
- Node.js (backend + collector) + React frontend web app (LLM chat / RAG). Repo: https://github.com/Mintplex-Labs/anything-llm

## Version / release
- Latest release: `v1.20.0` (from releases/latest redirect). api.github.com call hit rate limit (403), so the HTML redirect was used as the one alternative.
- Dockerfile sets `ENV DEPLOYMENT_VERSION=1.19.0` (lags the v1.20.0 tag at the pinned commit).

## Build (upstream Dockerfile, multi-stage)
- Base: `FROM ubuntu:noble-20251013 AS base`, `ARG ARG_UID=1000`, `ARG ARG_GID=1000`.
- Per-arch stages `build-arm64` / `build-amd64`, selected via `build-${TARGETARCH}`.
- apt packages (both arches): unzip curl gnupg libgfortran5 libgbm1 tzdata netcat-openbsd, many libgtk/libnss/libx* chromium libs, ca-certificates, fonts-liberation, git, build-essential, ffmpeg, libvulkan1, mesa-vulkan-drivers (arm64 also unzip).
- Node 24 from NodeSource repo (`node_24.x`), yarn 1.22.19 (.deb from GitHub), uv/uvx 0.6.10 via astral install.sh (moved to /usr/local/bin).
- Creates user/group `anythingllm` with ARG_UID/ARG_GID, home /app.
- arm64 only: downloads Chromium from https://webassets.anythingllm.com/chromium-1088-linux-arm64.zip to /app/chrome-linux; sets CHROME_PATH and PUPPETEER_EXECUTABLE_PATH=/app/chrome-linux/chrome.
- `frontend-build` stage: `FROM --platform=$BUILDPLATFORM node:24-slim`, `yarn install && yarn build` in /app/frontend; output copied to /app/server/public.
- backend: `yarn install --production` in /app/server and /app/collector. Collector sets `PUPPETEER_DOWNLOAD_BASE_URL=https://storage.googleapis.com/chrome-for-testing-public`.

## Runtime
- `USER anythingllm`, `WORKDIR /app`.
- ENV: NODE_ENV=production, ANYTHING_LLM_RUNTIME=docker, DEPLOYMENT_VERSION=1.19.0, PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true (arm64 stage).
- HEALTHCHECK: `--interval=1m --timeout=10s --start-period=1m`, `CMD /bin/bash /usr/local/bin/docker-healthcheck.sh`.
- ENTRYPOINT: `["/bin/bash", "/usr/local/bin/docker-entrypoint.sh"]`. No CMD.
- No EXPOSE, no VOLUME in Dockerfile.
- Copied helpers: /usr/local/bin/docker-entrypoint.sh, docker-healthcheck.sh; /app/server/.env from docker/.env.example.

## Entrypoint (docker-entrypoint.sh)
- Warns if STORAGE_DIR unset (data loss on restart).
- Runs in background: `cd /app/server && CHECKPOINT_DISABLE=1 npx prisma generate --schema=./prisma/schema.prisma && npx prisma migrate deploy --schema=./prisma/schema.prisma && node /app/server/index.js`
- Also `node /app/collector/index.js`.
- `wait -n; exit $?`.

## Gotchas
- Prisma generate and migrate run at container start, so the app writes under /app (server, collector) at runtime.
- Explicit Chromium zip download is in the arm64 stage only (amd64 stage Chromium handling not read).
