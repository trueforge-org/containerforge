# GitHub: bpatrik/pigallery2

## Source URL(s) + date
- https://api.github.com/repos/bpatrik/pigallery2/releases/latest
- https://raw.githubusercontent.com/bpatrik/pigallery2/43f348a254142eea521138b783e3b8df9fe547c8/docker/alpine/Dockerfile.build
- Fetched 2026-11-27

## Latest release
- tag `3.8.0`, published 2026-11-18T09:57:54Z.
- Single asset: `pigallery2-release.zip` (one zip for all arches).
- Download: `https://github.com/bpatrik/pigallery2/releases/download/3.8.0/pigallery2-release.zip`.

## Upstream Dockerfile.build (commit 43f348a254142eea521138b783e3b8df9fe547c8)
### Stages
- builder: `FROM node:26-alpine3.24`.
- main: `FROM node:26-alpine3.24`.

### Builder
- `ENV SHARP_FORCE_GLOBAL_LIBVIPS=1`.
- `apk add` vips, vips-dev, vips-heif, vips-magick, libheif, libpng, libjpeg-turbo, libde265, libwebp, libraw-dev, g++, make, gcc, build-base, python3, pkgconfig.
- `COPY pigallery2-release /app`; `WORKDIR /app`.
- `npm install --save-dev node-addon-api@8.9.2 node-gyp@13.1.0`; `npm prune --omit=dev`; `npm cache clean --force`.
- `mkdir -p /app/data/{config,db,images,tmp}`.

### Main
- `WORKDIR /app`.
- `ENV NODE_ENV=production`, `default-Database-dbFolder=/app/data/db`, `default-Media-folder=/app/data/images`, `default-Media-tempFolder=/app/data/tmp`, `default-Extensions-folder=/app/data/config/extensions`, `PI_DOCKER=true`.
- `EXPOSE 80`.
- `ARG TARGETARCH`; `apk add` vips, vips-cpp, vips-heif, vips-magick, ffmpeg; if amd64 also `intel-media-driver`.
- `COPY --from=builder /app /app`.
- RUN diagnostics: `node --expose-gc ./src/backend/index --run-diagnostics --config-path=/app/diagnostics-config.json --Server-Log-level=silly` (build-time check; note it runs during build).
- `HEALTHCHECK --interval=40s --timeout=30s --retries=3 --start-period=60s CMD wget --spider http://127.0.0.1:80/heartbeat`.
- `ENTRYPOINT ["node", "--expose-gc", "./src/backend/index", "--config-path=/app/data/config/config.json"]`.

### Not present
- USER, VOLUME, CMD, copied scripts.

## Ports
- 80 (EXPOSE and HEALTHCHECK).

## Config
- Config path `/app/data/config/config.json` (ENTRYPOINT).
- Env overrides use dotted-ish names with `default-` prefix (e.g. `default-Media-folder`); port setting key not in this file.

## Gotchas
- Diagnostics RUN in the main stage uses `--config-path=/app/diagnostics-config.json`.
- Node 26 alpine base.
- Native modules (sharp / vips) must match the arch.
