# webp-sh/webp_server_go

Source URL(s) + fetch date: https://github.com/webp-sh/webp_server_go · https://raw.githubusercontent.com/webp-sh/webp_server_go/master/README.md · https://raw.githubusercontent.com/webp-sh/webp_server_go/5efe1bf88814f86588d4c0f030a12d071d7471ae/Dockerfile · https://raw.githubusercontent.com/webp-sh/webp_server_go/0.16.2/config.json · https://github.com/webp-sh/webp_server_go/releases/tag/0.16.2 · fetched 2026-11-26

## What it is
- Go server that converts images to WebP (or AVIF) on the fly for a request URL such as `/pics/tsuki.jpg`. Inputs: JPEG, PNG, BMP, GIF, SVG, HEIC, NEF, WEBP. GIF is not converted to AVIF (not animated).
- License: GPLv3 (README; LICENSE file). SECURITY.md is present.

## Install/build steps and build deps
- Upstream Dockerfile at 5efe1bf (multi-stage):
  - Builder: `FROM golang:1.27-trixie AS builder`; `ARG IMG_PATH=/opt/pics`, `ARG EXHAUST_PATH=/opt/exhaust`; `apt install --no-install-recommends libvips-dev`; `go mod download`; `sed` rewrites config.json (`./pics` -> IMG_PATH, `""` -> EXHAUST_PATH, `127.0.0.1` -> `0.0.0.0`); `go build -ldflags="-s -w" -o webp-server .`.
  - Runtime: `FROM debian:trixie-slim`; `apt install --no-install-recommends libvips ca-certificates libjemalloc2 libtcmalloc-minimal4 curl libheif-plugin-aomenc libheif-plugin-aomdec`; then `rm -rf /var/lib/apt/lists/*`.
  - Copies `/build/webp-server` to `/usr/bin/webp-server` and `/build/config.json` to `/etc/config.json`.
- Build deps for source: Go 1.27 and `libvips-dev` (cgo, govips).

## Runtime deps
- libvips (runtime), libheif AOM plugins, ca-certificates. Upstream also installs libjemalloc2 and libtcmalloc-minimal4 (allocator preloads, not confirmed needed).

## Binaries/entrypoint/CLI flags
- Binary `webp-server`. Upstream CMD: `["/usr/bin/webp-server", "--config", "/etc/config.json"]`.
- CLI flags (plan.md, not re-read from docs): `--config`, `--prefetch`, `--prefetch-foreground`, `--jobs`, `--verbosity` (0-4), `--dump-config`, `-V`. Docs page says `./webp-server -dump-config > config.json` to dump config.

## Config files and formats
- `config.json` (JSON). Repo file at 0.16.2 (verbatim keys): `HOST` "127.0.0.1", `PORT` "3333", `QUALITY` "80", `IMG_PATH` "./pics", `EXHAUST_PATH` "./exhaust", `IMG_MAP` {}, `ALLOWED_TYPES` ["jpg","png","jpeg","gif","bmp","svg","heic","nef"], `CONVERT_TYPES` ["webp"], `STRIP_METADATA` true, `ENABLE_EXTRA_PARAMS` false, `READ_BUFFER_SIZE` 4096, `CONCURRENCY` 262144, `DISABLE_KEEPALIVE` false, `CACHE_TTL` 259200.
- `METADATA_PATH` is NOT a key in the 0.16.2 config.json; the docs/compose show `/opt/metadata` as a volume. plan.md lists it as a key (see README.md).
- Docs (docs.webp.sh) mount custom config at `/etc/config.json`.

## Env vars
- Per plan.md (config/config.go, not re-read here): `WEBP_HOST`, `WEBP_PORT`, `WEBP_IMG_PATH`, `WEBP_EXHAUST_PATH`, `WEBP_QUALITY`, `WEBP_ALLOWED_TYPES`, `WEBP_CONVERT_TYPES`, `WEBP_ENABLE_EXTRA_PARAMS`, `WEBP_STRIP_METADATA`, `WEBP_CACHE_TTL`, `WEBP_MAX_CACHE_SIZE`, `WEBP_CONCURRENCY`, `WEBP_DISABLE_KEEPALIVE`, `WEBP_READ_BUFFER_SIZE`, `WEBP_IMG_MAP`. The README does not name env vars.
- Note: the chart and the Docker Hub page refer to `ENABLE_AVIF` (no such key in the 0.16.2 config.json; docs mention AVIF output).

## Ports
- 3333/tcp (config PORT "3333"). Compose maps `127.0.0.1:3333:3333`.
- Upstream builds set `HOST` to `0.0.0.0` via `sed`.

## Volumes/paths and persistent data
- `/opt/pics`: source images (read-only in the chart).
- `/opt/exhaust`: converted cache (upstream `VOLUME /opt/exhaust`).
- `/opt/metadata`: source metadata for cache validation (compose example; not a config key in 0.16.2).
- `/etc/config.json`: optional custom config mount.
- Cache can be moved by changing `EXHAUST_PATH`.

## User/UID & permissions
- Upstream runtime image: no USER (root). Chart: runAsUser 0.

## Healthcheck/readiness endpoints
- None documented. Response headers on images: `Content-Type: image/webp`, `X-Compression-Rate`.

## Version/release info and asset naming
- Latest release `0.16.2`: published 06 Oct (no year on page), built on commit `5efe1bf` (verified signature). Notes: golang.org/x/image 0.45.0 -> 0.46.0 (#472); ImageMap prefix fix (#474).
- Release assets: page says 6 assets, list did not load. Names from draft/plan: `webp-server-linux-amd64`, `webp-server-linux-arm64` (single binaries). Checksums not visible on the page.
- Renovate: github-releases, versioning loose (plan.md); tags have no `v` prefix.

## Arch support
- Binary assets for linux amd64 and arm64 (names per draft/plan).

## Gotchas
- Docs (docs.webp.sh deployment/docker) compose uses image `webpsh/webp-server-go` (alt `ghcr.io/webp-sh/webp_server_go`). The draft uses `docker.io/webpsh/webps`, which the Docker Hub page describes as an older, binary-oriented listing.
- Docs warn that running the binary directly can cause glibc and library problems.
