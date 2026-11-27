# atuinsh/atuin (upstream repo, Dockerfile at d154a94)
Source URL(s): https://raw.githubusercontent.com/atuinsh/atuin/d154a94090a7e390c1685c10252128545cdcacbd/Dockerfile (fetched; blob variant same), https://raw.githubusercontent.com/atuinsh/atuin/main/README.md (fetched), https://raw.githubusercontent.com/atuinsh/atuin/main/LICENSE (fetched), https://github.com/atuinsh/atuin (repo page, merged via README)

## What it is
Atuin replaces shell history with a SQLite DB and optional end-to-end encrypted sync. This image is the sync SERVER only (`atuin-server`). Client is separate.

## Build (Dockerfile at d154a94)
- Builder: `lukemathwalker/cargo-chef:latest-rust-slim-bookworm@sha256:b4b459d3...` (chef stage), toolchain from rust-toolchain.toml via rustup
- Builder apt: build-essential libssl-dev pkg-config
- `COPY vendor vendor` needed (axoasset [patch.crates-io] path dep)
- `cargo chef cook --release`, `cargo build --release --bin atuin-server`
- Runtime: `debian:bookworm-20261020-slim`
- Runtime apt: ca-certificates curl libssl3 (--no-install-recommends, lists removed)
- User `atuin` created (`useradd -c 'atuin user' atuin`), `/config` created and chowned to atuin
- Binary copied to `/usr/local/bin/atuin-server`
- Labels: org.opencontainers.image.source, url https://atuin.sh, licenses MIT

## Entrypoint / cmd
- `ENTRYPOINT ["/usr/local/bin/atuin-server"]` (chart passes args `start`)

## Env (Dockerfile)
| Name | Value |
| --- | --- |
| TZ | Etc/UTC |
| RUST_LOG | atuin_server=info |
| ATUIN_CONFIG_DIR | /config |

## Ports
- No EXPOSE. Default port 8888 (from healthcheck `${ATUIN_PORT:-8888}`)

## Volumes / paths
- /config (owned by atuin); WORKDIR app

## User/UID
- `USER atuin` (uid not pinned)

## Healthcheck
- `HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 CMD curl -fsS -o /dev/null "http://localhost:${ATUIN_PORT:-8888}/healthz"`

## Runtime deps
- ca-certificates (webhooks), curl (healthcheck), libssl3, PostgreSQL (chart-configured)

## License
- MIT License, Copyright (c) 2026 Atuin, Inc. (LICENSE raw)

## Gotchas
- Upstream runtime base is a dated debian bookworm slim tag
- README: sync server self-hostable; hosted server also offered
