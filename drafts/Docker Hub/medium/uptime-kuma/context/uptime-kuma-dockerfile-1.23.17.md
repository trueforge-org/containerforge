# Uptime Kuma docker/dockerfile at 1.23.17

Source URL(s): https://raw.githubusercontent.com/louislam/uptime-kuma/1.23.17/docker/dockerfile (fetched 2026-11-27; blob URL is the same file)

## Stages
- `build_healthcheck` from `louislam/uptime-kuma:builder-go` (Go healthcheck; comment: run `npm run build-healthcheck-armv7` on host first for armv7).
- `build` from `louislam/uptime-kuma:base-debian`, `WORKDIR /app`.
  - `ENV PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=1`
  - `COPY .npmrc package.json package-lock.json`, `RUN npm ci --omit=dev`, `COPY . .`, copies `/app/extra/healthcheck` from build_healthcheck, `chmod +x /app/extra/entrypoint.sh`.
- `release` from `louislam/uptime-kuma:base-debian`: `WORKDIR /app`, `ENV UPTIME_KUMA_IS_CONTAINER=1`, copies `/app`.
- `nightly`: `npm run mark-as-nightly`.
- `pr-test`: installs git and gh keyring, clones upstream, `npm ci`, `CMD npm run start-pr-test`.
- `upload-artifact`: packs `dist` and uploads GitHub release asset (build tooling, not runtime).

## Runtime
- `EXPOSE 3001`
- `VOLUME ["/app/data"]`
- `HEALTHCHECK --interval=60s --timeout=30s --start-period=180s --retries=5 CMD extra/healthcheck`
- `ENTRYPOINT ["/usr/bin/dumb-init", "--", "extra/entrypoint.sh"]`
- `CMD ["node", "server/server.js"]`
- No `USER` in release stage.

## Gotchas
- Base images are `louislam/uptime-kuma:base-debian` and `builder-go` (upstream images, not fetched).
- `extra/entrypoint.sh` is copied into the image and run by the entrypoint.
