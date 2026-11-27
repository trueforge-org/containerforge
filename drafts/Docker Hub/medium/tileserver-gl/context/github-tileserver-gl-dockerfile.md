# GitHub maptiler/tileserver-gl Dockerfile (master)

Source URL(s) + date:
- https://raw.githubusercontent.com/maptiler/tileserver-gl/master/Dockerfile
- Fetched 2026-11-27

## Stages
1. Builder `FROM ubuntu:noble AS builder`
   - `ENV NODE_ENV="production"`, `SHELL ["/bin/bash", "-o", "pipefail", "-c"]`
   - apt build deps: build-essential python3-setuptools ca-certificates curl gnupg pkg-config xvfb libglfw3-dev libuv1-dev libcairo2-dev libpango1.0-dev libpng-dev libjpeg-dev libgif-dev librsvg2-dev libcurl4-openssl-dev libicu-dev
   - NodeSource repo `node_24.x` (key from deb.nodesource.com); `nodejs` installed; `npm i -g npm@latest`; curl gnupg removed
   - `WORKDIR /usr/src/app`; `COPY package.json package-lock.json ./`
   - `npm ci --omit=dev`; `npm_config_build_from_source=true npm rebuild canvas`
2. Final `FROM ubuntu:noble AS final`
   - `groupadd -r node && useradd -r -g node node`
   - runtime libs: ca-certificates curl gnupg xvfb libglfw3 libuv1 libicu74 libcairo2 libjpeg-turbo8 libgif7 libpng16-16t64 libopengl0 libcurl4 librsvg2-dev libpango-1.0-0 libjemalloc2
   - NodeSource Node 24, `npm i -g npm@latest`, jemalloc symlink at `/usr/lib/libjemalloc.so`
   - `ENV NODE_ENV=production CHOKIDAR_USEPOLLING=1 CHOKIDAR_INTERVAL=500 LD_PRELOAD=/usr/lib/libjemalloc.so MALLOC_CONF=...`
   - `COPY --from=builder /usr/src/app /usr/src/app`; `COPY . /usr/src/app`
   - `mkdir -p /data && chown node:node /data`; `VOLUME /data`; `WORKDIR /data`
   - `EXPOSE 8080`; `USER node:node`
   - `ENTRYPOINT ["/usr/src/app/docker-entrypoint.sh"]`
   - `HEALTHCHECK CMD node /usr/src/app/src/healthcheck.js`

## Gotchas
- Runs as `node:node` (UID assigned by `useradd -r`; not fixed to 1000 in this file).
- Health endpoint: `src/healthcheck.js` (not fetched). Docs: `/health` returns 503 while starting, 200 when running (see readthedocs-tileserver-gl.md).
- Entrypoint `docker-entrypoint.sh` (not fetched). Plan describes it as Xvfb start then `exec node`.
