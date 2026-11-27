# Upstream Dockerfile: toeverything/AFFiNE @ b4c8548 (.github/deployment/node/Dockerfile)

Source URL(s) + date: https://raw.githubusercontent.com/toeverything/AFFiNE/b4c8548c09da21b2898443559a5b846f0ccf5dd8/.github/deployment/node/Dockerfile (fetched 2026-11-27; blob URL is the same file)

## Build (2 stages, node:22-bookworm-slim)
- Stage `assets`: WORKDIR /app; COPY ./packages/backend/server -> /app; COPY frontend dists to /app/static (web), /app/static/admin (admin), /app/static/mobile (mobile).
  - ARG TARGETARCH, TARGETVARIANT.
  - apt install openssl ca-certificates (Prisma engine).
  - `AFFINE_DOCKER_CLEAN=1 TARGETARCH=... TARGETVARIANT=... node ./scripts/docker-clean.mjs` (strips sourcemaps/node_modules bits per comment).
- Final stage: node:22-bookworm-slim; WORKDIR /app; COPY --from=assets /app /app.
  - apt install openssl libjemalloc2.
  - ENV LD_PRELOAD=libjemalloc.so.2.
  - EXPOSE 3010.
  - CMD ["node", "./dist/main.js"].
- No USER (runs as root), no HEALTHCHECK, no VOLUME, no ENTRYPOINT.

## Runtime deps
- Postgres (pgvector required per chart) and Redis (chart uses Valkey).
- Prisma engine (openssl).

## Arch
- Build args TARGETARCH/TARGETVARIANT used by docker-clean.mjs.

## Gotchas
- Dockerfile uses `# syntax=docker/dockerfile:1.7`.
- Image runs as root; chart keeps runAsUser 0.
