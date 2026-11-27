# GitHub: connorgallopo/Tracearr docker/Dockerfile (commit a0037ccf)

Source URL(s): https://raw.githubusercontent.com/connorgallopo/Tracearr/a0037ccf60ceb3d26c9e0efbb2605fec47471322/docker/Dockerfile (fetched 2026-11-27)

## Build stage (node:26-alpine3.23, digest-pinned)
- ARG PNPM_VERSION=12.20.0 (renovate-annotated); `npm install -g --allow-scripts=pnpm pnpm@${PNPM_VERSION}`.
- COPY workspace package.json files; `pnpm install --frozen-lockfile`; `COPY --exclude=data . .`.
- `pnpm turbo run build --filter=@tracearr/shared --filter=@tracearr/server --filter=@tracearr/web`.

## Runner stage (same node base)
- `apk upgrade`; apk add `postgresql-client`.
- Tailscale static binary: ARG TAILSCALE_VERSION=1.104.7 (renovate), from pkgs.tailscale.com/stable/tailscale_${V}_${TARGETARCH}.tgz -> /usr/bin/tailscale, /usr/sbin/tailscaled.
- Group nodejs gid 1001; user `tracearr` uid 1001 (system).
- ENV IMAGE_CACHE_DIR=/data/tracearr/image-cache; NODE_ENV=production.
- Copies data/basemap.pmtiles, data/BASEMAP_NOTICE.txt, data/GeoLite2-City.mmdb, data/GeoLite2-ASN.mmdb (MaxMind, refreshed at build).
- `pnpm install --prod --frozen-lockfile --ignore-scripts --filter @tracearr/server...`.
- Copies from builder: apps/server/dist, apps/server/scripts, apps/web/dist, packages/shared/dist, packages/emails/dist, apps/server/src/db/migrations, assets/logo.png.
- RUN mkdir -p /app/data/image-cache /data/tracearr/image-cache /data/backup; chown tracearr.
- COPY docker/entrypoint.sh /entrypoint.sh (chmod +x).
- USER tracearr.
- ARG APP_VERSION, APP_TAG, APP_COMMIT, APP_BUILD_DATE, CACHE_BUST; writes /app/.build-info.json; ENV copies of these.
- EXPOSE 3000.
- HEALTHCHECK 30s/10s/5s/3: `wget --spider http://127.0.0.1:3000/health`.
- LABEL org.opencontainers.image.licenses="AGPL-3.0", source https://github.com/connorgallopo/Tracearr.
- ENTRYPOINT ["/entrypoint.sh"]; CMD ["node","apps/server/dist/index.js"].

## Ports
- 3000/tcp

## Volumes/paths
- /data/tracearr/image-cache (IMAGE_CACHE_DIR, Helm PVC path), /data/backup, /app/data/image-cache.

## User/UID
- tracearr uid 1001, group nodejs gid 1001.

## Runtime deps
- Node 26 alpine, pnpm, postgresql-client, tailscale binaries (userspace).

## Gotchas
- IMAGE_CACHE_DIR must be a path the image creates and chowns; server cannot recover from EACCES (per Dockerfile comment).
- Dockerfile.supervised exists upstream (referenced, not fetched).
