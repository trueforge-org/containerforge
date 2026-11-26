# shawly/docker-ps3netsrv (GitHub, third-party Docker wrapper)

Source URL(s) + fetch date (2026-11-26):
- https://github.com/shawly/docker-ps3netsrv (README via https://raw.githubusercontent.com/shawly/docker-ps3netsrv/master/README.md)
- https://github.com/shawly/docker-ps3netsrv/blob/0585a23954e9b3ca27cc978ddc479af10e363ad1/alpine.Dockerfile (fetched as raw at that commit)

## What it is
Alpine (default) and Debian-slim Docker images that package aldostools/ps3netsrv. Runs as non-root with UID/GID from env. Uses s6-overlay as init (`ENTRYPOINT ["/init"]`). Builds from git master by default, or from a release tag when BUILD_FROM_GIT=false.

## Install/build steps and build deps (alpine.Dockerfile, commit 0585a23)
Builder stage `FROM alpine:3.24 AS builder`:
- apk: build-base, curl, git, meson, musl-dev, tar, xz; mbedtls3-dev (fallback mbedtls-dev).
- Build args: `PS3NETSRV_REPO=https://github.com/aldostools/ps3netsrv.git`, `PS3NETSRV_SRC_REF=master`, `PS3NETSRV_VERSION` (required when BUILD_FROM_GIT=false), `BUILD_FROM_GIT=true`, `S6_OVERLAY_VERSION=v3.2.3.2`, `S6_OVERLAY_DOWNLOAD_URL=https://github.com/just-containers/s6-overlay/releases/download`, TARGETARCH, TARGETVARIANT.
- Release source: `https://github.com/aldostools/ps3netsrv/archive/refs/tags/${PS3NETSRV_VERSION}.tar.gz` extracted with --strip-components=1.
- Patch: `sed -i 's/\boff64_t\b/off_t/g' include/*.* src/*.*` for musl.
- Appends a constructor to src/main.cpp for line-buffered stdout.
- Builds two flavours: mbedTLS via meson (`meson build --buildtype=release -Dc_args=-DBUILD_DATE=... -Dcpp_args=...`, `ninja -C build/`, output `ps3netsrv-mbedtls`), and PolarSSL via `make -f Makefile.linux BUILD_DATE=...` (output `ps3netsrv-polarssl`).
- s6-overlay: noarch + arch tarball from `${S6_OVERLAY_DOWNLOAD_URL}/${S6_OVERLAY_VERSION}/s6-overlay-${tarball}.tar.xz`. Arch map: amd64->x86_64, 386->i486, arm64->aarch64, armv7->arm, armv6->armhf.

Runtime stage `FROM alpine:3.24`:
- apk: bash, coreutils, findutils, libstdc++, shadow, tzdata, mbedtls3 (fallback mbedtls).
- User: `useradd -u 1000 -U -M -s /bin/false ps3netsrv`, `usermod -G users ps3netsrv`; `/var/log/ps3netsrv` owned by nobody:nogroup.
- COPY binaries `/usr/bin/ps3netsrv-*`, s6 rootfs, `rootfs/` overlay.
- ENV `PS3NETSRV_BINARY=mbedtls`, `PS3NETSRV_PORT=38008`, `PS3NETSRV_WHITELIST=`.
- `VOLUME ["/games"]`, `EXPOSE 38008`.
- HEALTHCHECK `--interval=30s --timeout=10s --start-period=20s --retries=3 CMD ["/usr/local/bin/ps3netsrv-healthcheck"]`.
- `ENTRYPOINT ["/init"]`. No USER instruction, no CMD.

## Runtime deps
libstdc++, mbedtls3 (or PolarSSL binary, static), bash, coreutils, findutils, shadow, tzdata.

## Binaries/entrypoint/CLI flags
- Entry: s6 `/init`. Binaries: `/usr/bin/ps3netsrv-mbedtls`, `/usr/bin/ps3netsrv-polarssl`. Selected via PS3NETSRV_BINARY.
- Healthcheck script: `/usr/local/bin/ps3netsrv-healthcheck` (from rootfs/).

## Env vars (from README)
| Variable | Default | Purpose |
| --- | --- | --- |
| PUID | 1000 | UID the app runs as |
| PGID | 1000 | GID the app runs as |
| PS3NETSRV_PORT | 38008 | Listening port; change only with host networking |
| PS3NETSRV_WHITELIST | empty | Allowed client IPs/ranges, e.g. 192.168.1.*; likely only effective with host networking |
| PS3NETSRV_BINARY | mbedtls | mbedtls or polarssl; try other if decryption misbehaves |
| UMASK | 022 | umask for process |
| PS3NETSRV_SKIP_CHECKS | false | true skips startup /games structure/permission check |
| PS3NETSRV_FIX_PERMISSIONS | false | true chown/chmod everything under /games at start (destructive; no effect on ACL shares) |
| PS3NETSRV_FOLDER_PERMISSIONS | 755 | dir mode when fix is on |
| PS3NETSRV_FILE_PERMISSIONS | 644 | file mode when fix is on |
| TZ | Etc/UTC | timezone (mapping /etc/localtime also works) |

## Ports
- 38008 (EXPOSE). Compose example maps 38008:38008.

## Volumes/paths and persistent data
- `/games` (rw): must contain at least `PS3ISO` (ISO files) and `GAMES` (folder games).

## User/UID & permissions
- Wrapper runs as UID/GID from PUID/PGID (default 1000); README says set PUID/PGID to owner of games folder.
- Dockerfile creates user ps3netsrv uid 1000 but no USER instruction; s6 handles privilege drop.

## Healthcheck/readiness
- Healthy when ps3netsrv holds the listening socket and the /games check passed (or is skipped). Port check alone during /games check. `PS3NETSRV_SKIP_CHECKS=true` drops the /games check.
- Inspect: `docker inspect --format '{{json .State.Health}}' ps3netsrv`.

## Version/release info and asset naming
- Repo tags `v2.1.0`-style mark wrapper releases.
- Image tags: `latest`, `alpine`, date tags (e.g. `20261110`) = Alpine; `slim`, `trixie-slim` = Debian glibc; `edge` = upstream master; `v2.1.0-alpine3.24` seen on Docker Hub.

## Arch support
- Dockerfile maps amd64, 386, arm64, armv7, armv6 for s6-overlay (so those are the arches the build targets). Docker Hub page only mentions "arm support".

## Gotchas
- Dockerfile comment: image tags are literal for Dependabot; do not ARG-interpolate FROM.
- Upstream README says the /games mount is mandatory.
