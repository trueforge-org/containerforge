# openobserve/openobserve (Dockerfile at pinned commit + release v1.1.2)

## Source URL(s) + date
- https://raw.githubusercontent.com/openobserve/openobserve/d16d693ba99bc20621a58b948ecbcad7ec7fa882/deploy/build/Dockerfile.tag.amd64 (fetched 2026-11-27)
- https://github.com/openobserve/openobserve/releases/tag/v1.1.2 (fetched 2026-11-27, HTML; commit d16d693 shown)

## Dockerfile.tag.amd64 (pinned commit d16d693)
- Stage 1 `webbuilder`: `public.ecr.aws/docker/library/node:24-trixie`; `COPY ./web`; `npm install`; `NODE_OPTIONS="--max-old-space-size=8192" npm run build`.
- Stage 2 `builder`: `public.ecr.aws/zinclabs/rust:trixie-sccache`; WORKDIR /openobserve; copies source and `web/dist`.
  - `cargo build --profile release-prod --features mimalloc --target x86_64-unknown-linux-gnu`
  - moves binary to `/openobserve/target/release/openobserve`.
- Stage 3 `runtime`: `gcr.io/distroless/cc-debian13`.
  - copies binary to `/openobserve`.
  - copies `liblzma.so.5`, `libz.so.1`, `libbz2.so.1.0` from `/lib/x86_64-linux-gnu/`.
  - `RUN ["/openobserve", "init-dir", "-p", "/data/"]` (runtime stage, build time).
  - `CMD ["/openobserve"]`.
- Amd64 only (target x86_64). Distroless runtime: no shell.

## Version / asset naming
- Release tag `v1.1.2`, commit `d16d693`.
- Release API (api.github.com) was rate-limited; asset names not retrieved.

## Gotchas
- Build needs Node 24 and Rust toolchain (sccache base); large memory for npm build (8 GB heap setting).
- Runtime is distroless: no shell, no package manager; `init-dir` creates `/data`.
