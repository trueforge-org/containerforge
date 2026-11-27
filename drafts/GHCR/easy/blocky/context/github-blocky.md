# GitHub 0xERR0R/blocky (latest release v0.37.0, license, Dockerfile)

## Source URL(s) + date
- https://api.github.com/repos/0xERR0R/blocky/releases/tags/v0.37.0 (fetched 2026-11-27)
- https://api.github.com/repos/0xERR0R/blocky/license (fetched 2026-11-27)
- https://raw.githubusercontent.com/0xERR0R/blocky/master/Dockerfile (fetched 2026-11-27)
- https://raw.githubusercontent.com/0xERR0R/blocky/2d6f7d4be5e39717c9ebb66c365d7ab2ae620edd/Dockerfile (pinned commit, identical to master, fetched 2026-11-27)

## What it is
- Apache-2.0 (license API, SPDX Apache-2.0, file LICENSE).
- Release v0.37.0, published 2026-11-21T21:55:11Z, not a prerelease.

## Release assets (v0.37.0)
- `blocky_checksums.txt`
- Linux: `blocky_v0.37.0_Linux_x86_64.tar.gz`, `blocky_v0.37.0_Linux_arm64.tar.gz`, `blocky_v0.37.0_Linux_armv6.tar.gz`, `blocky_v0.37.0_Linux_armv7.tar.gz`, `blocky_v0.37.0_Linux_mips64le_softfloat.tar.gz`, `blocky_v0.37.0_Linux_mips64_softfloat.tar.gz`, `blocky_v0.37.0_Linux_mipsle_softfloat.tar.gz`, `blocky_v0.37.0_Linux_mips_softfloat.tar.gz`

## Dockerfile (master = pinned commit 2d6f7d4)
- Build: `FROM --platform=$BUILDPLATFORM golang:alpine AS build`; apk make coreutils libcap; `GO_SKIP_GENERATE=1`, `CGO_ENABLED=0`, `BIN_USER=100`, `BIN_AUTOCAB=1`, `BIN_OUT_DIR=/bin`; `go mod download`; `make build` with GOOS/GOARCH/GOARM from TARGETOS/TARGETARCH/TARGETVARIANT.
- Build also `mkdir -p /seed-dir`.
- Final: `FROM scratch`; `USER 100`; `WORKDIR /app`; `COPY --from=build /bin/blocky /app/blocky`; seed dirs copied to `/app/cache` and `/logs` (owned 100:100).
- `ENV BLOCKY_CONFIG_FILE=/app/config.yml`
- `ENTRYPOINT ["/app/blocky"]`
- `HEALTHCHECK --start-period=1m --timeout=3s CMD ["/app/blocky", "healthcheck"]`
- LABELs: licenses Apache-2.0, source https://github.com/0xERR0R/blocky, documentation `https://0xerr0r.github.io/blocky/${DOC_PATH}/`.

## Runtime deps
- Static Go binary (CGO-free, tags static). No shared libs needed. Image is scratch upstream.

## Entrypoint/flags
- `/app/blocky` (no args in upstream); `blocky healthcheck` subcommand used by HEALTHCHECK.
- `--config` accepts a file or a folder of *.yml/*.yaml (docs).

## Env vars
| Name | Value |
| --- | --- |
| BLOCKY_CONFIG_FILE | /app/config.yml (upstream default) |

## Ports
- Not EXPOSEd in upstream Dockerfile. Defaults per docs (see blocky-docs.md).

## User/UID
- UID 100 (`USER 100`).

## Volumes/paths
- `/app/cache` (seeded, cachePath recommended target), `/logs` (queryLog CSV target in Docker).

## Version/asset naming
- Tag `v0.37.0`; archive names `blocky_v0.37.0_Linux_<arch>.tar.gz` (tag with `v`); checksums `blocky_checksums.txt`.

## Arch
- Linux x86_64, arm64, armv6, armv7, mips/mips64 (softfloat variants).
