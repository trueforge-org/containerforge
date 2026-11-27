# immich server Dockerfile (upstream)

Source URL(s) + date: https://raw.githubusercontent.com/immich-app/immich/v3.4.2/server/Dockerfile · fetched 2026-11-27 (first ~5000 chars; tail truncated)

## Build
- Multi-stage: builder (base-server-dev) -> sdk -> plugin-sdk -> server / web / cli / plugins.
- Builder: corepack pnpm; `pnpm --filter immich build`, `pnpm --filter immich --prod deploy /output/server-pruned`.
- sharp built with `SHARP_FORCE_GLOBAL_LIBVIPS=true`.
- web: `pnpm --filter immich-web build` -> /build/www.
- cli: `@immich/cli` -> /output/cli-pruned; symlinked as server/bin/immich.
- plugins: mise (ver 2026.10.20 pinned by digest) `mise //:plugins`.

## Runtime (final stage)
- Base: ghcr.io/immich-app/base-server-prod:202610291416 (digest pinned)
- WORKDIR /usr/src/app; ENV NODE_ENV=production, NVIDIA_DRIVER_CAPABILITIES=all, NVIDIA_VISIBLE_DEVICES=all
- PATH adds /usr/src/app/server/bin
- Also copies restic-proxy (futo-org/backups v1.11.2) and restic (futo-org 0.19.1-futo.2) into /usr/local/bin and /usr (tail not fetched)
- Build args: BUILD_ID, BUILD_IMAGE, BUILD_SOURCE_REF, BUILD_SOURCE_COMMIT

## Gotchas
- Tail of the file (ENTRYPOINT/CMD/USER) not captured; check raw file before relying on it.
