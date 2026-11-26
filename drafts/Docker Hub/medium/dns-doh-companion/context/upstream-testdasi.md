# testdasi/simple-dns-doh (upstream image source)

## Source URL(s) + date
- https://raw.githubusercontent.com/testdasi/simple-dns-doh/354be66/Dockerfile (fetched 2026-11-26)
- https://raw.githubusercontent.com/testdasi/simple-dns-doh/354be66/install.sh
- https://raw.githubusercontent.com/testdasi/simple-dns-doh/354be66/README.md
- https://raw.githubusercontent.com/testdasi/simple-dns-doh/354be66/config.yml: 404 (failed, no alternative tried; file is not required by the Dockerfile)
- Docker Hub tags: https://hub.docker.com/v2/repositories/testdasi/simple-dns-doh/tags/?page_size=5 (fetched, amd64 image last pushed 2025-07-05)

## What it is
"A minimalist DNS server using cloudflared to connect to DNS-over-HTTPS services." Upstream README has no run/config docs beyond that line and a donation note.

## Install/build steps (upstream Dockerfile)
- `ARG FRM='testdasi/debian-slim-base'`, `ARG TAG='latest'`; `FROM ${FRM}:${TAG}`
- `ARG TARGETPLATFORM`
- `ADD cloudflared /tmp` (a prebuilt cloudflared file in the repo build context)
- `COPY ./install.sh /`, `RUN /bin/bash /install.sh && rm -f /install.sh`
- `EXPOSE 53/tcp 53/udp`
- `CMD cloudflared --config /etc/cloudflared/config.yml`

## install.sh (bash)
- `apt-get -y update && apt-get -y install dnsutils`
- Downloads `https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-<arch>.deb` to `/tmp/cloudflared.deb` per `TARGETPLATFORM` (arm64, amd64, 386, arm/v7; others commented out). Uses `dpkg --add-architecture`.
- Writes `/build.info` lines.
- Note: it uses `releases/latest` (unpinned), while the Dockerfile `ADD`s a separate `cloudflared` file. Only the first 1500 bytes of install.sh were read (the arm/v6 branch and the rest of the file were not reviewed).

## Runtime deps
- cloudflared (from `.deb` or added file). `dnsutils` (dig/nslookup) installed upstream.

## Entrypoint/flags
- `CMD cloudflared --config /etc/cloudflared/config.yml` (no ENTRYPOINT).

## Env vars
- None set in upstream Dockerfile.

## Ports
- 53/tcp and 53/udp (`EXPOSE`).

## Volumes/paths
- None declared upstream. Config path `/etc/cloudflared/config.yml` (referenced by CMD, not provided).

## User/UID
- Upstream: root (no USER).

## Config files
- `/etc/cloudflared/config.yml` expected by CMD. The repo's `config.yml` returned 404 in this pass, so its contents are unknown.

## Healthcheck
- None upstream.

## Version/asset naming
- Upstream image is unpinned: it fetches cloudflared "latest" at build time.
- Docker Hub: `testdasi/simple-dns-doh` tags list (page size 5) has amd64 images last pushed 2025-07-05.

## Arch
- amd64, arm64, 386, arm/v7 handled in install.sh.

## Gotchas
- Upstream image pulls cloudflared "latest" at build time, not a pinned version.
- Upstream README contains no usage docs.
