# luigi311/tanoshi Dockerfile

Source URL: https://raw.githubusercontent.com/luigi311/tanoshi/main/Dockerfile (fetched 2026-11-26)

## Build stages
- Builder base: `FROM ghcr.io/luigi311/tanoshi-builder:sha-d949faa AS base`
- `FROM base AS builder`
  - `COPY --chown=ubuntu:ubuntu . .` (builder runs as non-root `ubuntu`; `--chown` needed for trunk/cargo writes)
  - `RUN cd crates/tanoshi-web && trunk build --release` (web frontend)
  - `RUN cargo build -p tanoshi --release` (backend)
- Runtime: `FROM ubuntu:26.04 AS runtime`

## Runtime stage
- Packages: `apt update && apt upgrade -y && apt install --reinstall -y tini ca-certificates libssl3 libxml2-dev libnettle8t64`
- `WORKDIR /app`
- `COPY --from=builder /app/target/release/tanoshi .`
- `RUN chmod +x tanoshi`

## Env (set in image)
| Var | Value |
| --- | --- |
| PORT | 80 |
| TANOSHI_LOG | info |
| TANOSHI_HOME | /tanoshi |

## Entrypoint / ports
- `EXPOSE $PORT` (80)
- `ENTRYPOINT ["/bin/tini", "--", "/app/tanoshi"]`
- No CMD, VOLUME, USER lines in file (runs as image default user, root)

## Gotchas
- Final stage uses ubuntu:26.04 with tini at /bin/tini.
- Builder image is pinned by sha tag, not semver.
