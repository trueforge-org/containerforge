# Vertex docker/Dockerfile (master; identical to commit ec6fa1e6)

Source URL(s): https://raw.githubusercontent.com/vertex-app/vertex/master/docker/Dockerfile and https://raw.githubusercontent.com/vertex-app/vertex/ec6fa1e6de502b8069ee0416d397ca419713473e/docker/Dockerfile (both fetched 2026-11-27; byte-identical)

## Stages
1. `dependencies`: `FROM lswl/vertex-base:latest` (unpinned), `WORKDIR /app/vertex`.
   - `COPY package.json package-lock.json ./`
   - `apk add --no-cache gcc g++ python3 cmake make npm libc-dev`
   - `npm install --global npm@8.19.4` (for Node 14 compat, lockfile v3)
   - `PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true npm ci --omit=dev --no-audit --no-fund`
2. Final: `FROM lswl/vertex-base:latest`, `LABEL maintainer="lswl.in"`.
   - `ENV TZ=Asia/Shanghai`, `WORKDIR /app/vertex`.
   - `COPY --from=dependencies /app/vertex/node_modules ./node_modules`, `COPY package.json package-lock.json`, `COPY app ./app`, `COPY docker/start.sh ./docker/start.sh`.

## Data layout (RUN)
- `mkdir /vertex`; symlinks: `/app/vertex/app/data -> /vertex/data`, `app/db -> /vertex/db`, `/app/vertex/logs -> /vertex/logs`, `/app/vertex/torrents -> /vertex/torrents`.
- `mv app/config app/config_backup`; `ln -s /vertex/config app/config`.
- `ln -s /app/localtime /etc/localtime`; `ln -s /usr/bin/chromium-browser /usr/bin/chromium`; `chmod +x /usr/bin/chromium`.
- Redis config: appends `bind 127.0.0.1` and `daemonize yes` to `/app/redis.conf`.
- `useradd -d /app/vertex -s /bin/sh vt`; `chown -R vt /vertex`; `chmod +x /vertex`.

## Runtime
- `EXPOSE 3000`
- `CMD ["bash", "/app/vertex/docker/start.sh"]`
- No `USER` line (runs as root unless start.sh drops privileges). No `VOLUME`.

## Gotchas
- Base `lswl/vertex-base:latest` is unpinned and not fetched.
- Node 14 compatibility is implied by the npm@8 comment (base Node version not confirmed here).
- `docker/start.sh` is not fetched; its env vars and redis launch are unverified here.
