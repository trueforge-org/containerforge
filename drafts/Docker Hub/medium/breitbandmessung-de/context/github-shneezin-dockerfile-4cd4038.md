# shneezin/breitbandmessung-node Dockerfile @ 4cd4038

Source: https://raw.githubusercontent.com/shneezin/breitbandmessung-node/4cd4038/Dockerfile (fetched 2026-11-26)

## Base / ENV
- `FROM node:16.16.0-alpine` (single stage); WORKDIR /usr/src/app
- ENV DISTRO=alpine; PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=1; PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium-browser

## Steps
- `apk update`; `apk add --no-cache` procps (x2), chromium, harfbuzz, ca-certificates, ttf-freefont, freetype, nss, bash, yarn, tini
- `rm -rf /var/cache/apk/*`
- ADD ./puppeteer_build/package.json and yarn.lock to `/`; `yarn install` there (system-wide /node_modules)
- `mkdir /export`
- COPY package.json, yarn.lock, index.js, config.cfg.defaults, config.shlib -> WORKDIR; `yarn install` again in WORKDIR
- COPY entrypoint.sh -> /usr/local/bin/docker-entrypoint.sh

## Runtime
- ENTRYPOINT exec form: tini `--` docker-entrypoint.sh
- CMD none (commented alternatives: tail -f /dev/null)
- USER not set (root)
- EXPOSE none; VOLUME none (/export created)
- Download URLs: none

## Gotchas
- Dockerfile.debian variant exists (not fetched)
