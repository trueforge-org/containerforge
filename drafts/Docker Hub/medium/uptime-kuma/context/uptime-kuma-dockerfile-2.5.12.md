# Uptime Kuma docker/dockerfile at 2.5.12

Source URL(s): https://raw.githubusercontent.com/louislam/uptime-kuma/2.5.12/docker/dockerfile (fetched 2026-11-27)

## Stages
- `ARG BASE_IMAGE=louislam/uptime-kuma:base2`
- `build_healthcheck` from `louislam/uptime-kuma:builder-go` (Go healthcheck; host-side armv7 build note).
- `build` from `louislam/uptime-kuma:base2`, `USER node`, `WORKDIR /app`.
  - `ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=1`
  - `COPY --chown=node:node .npmrc package.json package-lock.json`, `RUN npm ci --omit=dev`, `COPY . .`, healthcheck copied from build_healthcheck, `RUN mkdir ./data`.
- `release` from `$BASE_IMAGE`: `WORKDIR /app`, `ENV UPTIME_KUMA_IS_CONTAINER=1`, copies `/app` from build (chown node).
  - `LABEL org.opencontainers.image.source="https://github.com/louislam/uptime-kuma"`
  - No `USER` line in release stage.
- `rootless`: from release, `USER node`.
- `nightly`: from release, `npm run mark-as-nightly`.
- `nightly-rootless`: from nightly, `USER node`.
- `pr-test2`: from base2, installs git and gh, clones upstream, `npm ci`, `CMD npm run start-pr-test`.
- `upload-artifact`: build tooling, packs `dist`.

## Runtime
- `EXPOSE 3001`
- No `VOLUME`.
- `HEALTHCHECK --interval=60s --timeout=30s --start-period=180s --retries=5 CMD extra/healthcheck`
- `ENTRYPOINT ["/usr/bin/dumb-init", "--"]`
- `CMD ["node", "server/server.js"]`

## Gotchas
- No `extra/entrypoint.sh` in ENTRYPOINT (differs from 1.23.17).
- Data directory is not declared in the Dockerfile. Data path override env is not shown in this file.
- `base2` image contents not fetched.
