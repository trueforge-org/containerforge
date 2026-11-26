# Upstream Dockerfile (spikecodes/libreddit @ 9b7ee50)

## Source URL(s) + date
- https://raw.githubusercontent.com/spikecodes/libreddit/9b7ee50/Dockerfile (2026-11-26)
- Not fetched (same as raw): https://github.com/spikecodes/libreddit/blob/9b7ee50/Dockerfile

## Full file (summary of exact steps)
- Stage 1 `FROM rust:alpine AS builder`: `apk add --no-cache musl-dev`; `WORKDIR /libreddit`; `COPY . .`; `cargo build --target x86_64-unknown-linux-musl --release`.
- Stage 2 `FROM alpine:latest`: COPY ca-certificates from builder (`/usr/share/ca-certificates`, `/etc/ssl/certs`); COPY `/libreddit/target/x86_64-unknown-linux-musl/release/libreddit` -> `/usr/local/bin/libreddit`.
- `adduser --home /nonexistent --no-create-home --disabled-password libreddit`; `USER libreddit`.
- `EXPOSE 8080`.
- `HEALTHCHECK --interval=1m --timeout=3s CMD wget --spider --q http://localhost:8080/settings || exit 1`.
- `CMD ["libreddit"]`.

## Build deps
- Rust toolchain (`rust:alpine`), `musl-dev`. Target fixed to x86_64 musl.

## Runtime deps
- None beyond ca-certificates (static musl binary in alpine).

## Entrypoint/flags
- `CMD ["libreddit"]`; no flags. Default bind `0.0.0.0:8080` (README).

## Env vars
- See github-libreddit-readme.md (LIBREDDIT_* instance and LIBREDDIT_DEFAULT_* user settings). None set in this Dockerfile.

## Ports
- 8080.

## Volumes/paths
- None.

## User/UID
- `libreddit` system user (adduser, no explicit UID), no home.

## Arch
- Build target hardcoded to `x86_64-unknown-linux-musl`: this Dockerfile yields amd64 only. Docker Hub arm tags come from other builds.

## Gotchas
- Stage 2 uses `alpine:latest` (unpinned).
