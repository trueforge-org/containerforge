# dani-garcia/vaultwarden docker/Dockerfile.debian @ 6ed6921cc2b0e03b4d74189574d2a5e71c512e97

Source URL(s): https://raw.githubusercontent.com/dani-garcia/vaultwarden/6ed6921cc2b0e03b4d74189574d2a5e71c512e97/docker/Dockerfile.debian (fetched 2026-11-27, 203 lines). Generated from Jinja2 template (DockerSettings.yaml / Dockerfile.j2). Alpine variant not fetched.

## Stages
| Stage | Base (pinned) |
| --- | --- |
| vault | docker.io/vaultwarden/web-vault@sha256:7baaa7d5349742548b6c44e557c1512157b22010cdf314ccc399ffdcacb5eb52 (web-vault tag v2026.10.1 per comment) |
| xx | docker.io/tonistiigi/xx@sha256:40fe21f44bb8cddf1eb1226db190d0a984118f62ee02a91b77d99448d28264a6 |
| build | docker.io/library/rust:1.99.1-slim-trixie (--platform=$BUILDPLATFORM) |
| runtime | docker.io/library/debian:trixie-slim (--platform=$TARGETPLATFORM) |

## Build (stage build)
- ENV DEBIAN_FRONTEND=noninteractive, TZ=UTC, CARGO_HOME=/root/.cargo.
- apt: clang, git (native); xx-apt-get: libpq-dev, libpq5, libssl-dev, libmariadb-dev, pkg-config, zlib1g-dev, xx-c-essentials.
- Cargo: `xx-cargo build --features ${DB} --profile ${CARGO_PROFILE}`; ARG DB=sqlite,mysql,postgresql; CARGO_PROFILE=release; ARG VW_VERSION.
- Cortex-A53 linker flag on arm64 (`-Clink-arg=-Wl,--fix-cortex-a53-843419`).
- Binary: /app/target/final/vaultwarden.

## Runtime stage
- ENV ROCKET_PROFILE=release, ROCKET_ADDRESS=0.0.0.0, ROCKET_PORT=80, DEBIAN_FRONTEND=noninteractive.
- `RUN mkdir /data`; apt: ca-certificates curl libmariadb3 libpq5 openssl.
- COPY docker/healthcheck.sh docker/start.sh -> /; COPY --from=vault /web-vault ./web-vault; COPY --from=build /app/target/final/vaultwarden .
- WORKDIR /. VOLUME /data. EXPOSE 80.
- `HEALTHCHECK --interval=60s --timeout=10s CMD ["/healthcheck.sh"]`.
- `CMD ["/start.sh"]`.

## Entrypoint
- /start.sh (not fetched; upstream script).

## Env vars (upstream)
| Var | Value |
| --- | --- |
| ROCKET_PROFILE | release |
| ROCKET_ADDRESS | 0.0.0.0 |
| ROCKET_PORT | 80 |

Other config vars (DATA_FOLDER, DOMAIN, ADMIN_TOKEN, DATABASE_URL) are not set in this file.

## Ports / Volumes
- 80/tcp; /data (VOLUME). Web vault served from /web-vault (cwd /).

## Healthcheck
- /healthcheck.sh every 60s, timeout 10s.

## Gotchas
- Full web-vault and xx digests are in this file (the plan's truncated values can be replaced with these full ones).
- Runtime is Debian trixie-slim; build stage Rust trixie-slim.
- Upstream runs as root (no USER line in this file).
