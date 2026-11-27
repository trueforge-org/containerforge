# kmahyyg/ztncui-aio Dockerfile @ v2024.1.28-r1

## Source URL(s) + date
- https://raw.githubusercontent.com/kmahyyg/ztncui-aio/v2024.1.28-r1/Dockerfile (fetched 2026-11-27)
- Duplicate in urls.txt (github blob URL) not fetched separately.
- api.github.com repo and releases/tags endpoints: 403 (see README).

## Stages
- `jsbuilder`: `FROM debian:bullseye-slim`. ARG/ENV `NODEJS_MAJOR=18`, `DEBIAN_FRONTEND=noninteractive`. WORKDIR `/build`. `ADD VERSION .`. apt: curl gnupg2 ca-certificates zip unzip build-essential git, then nodejs. Runs `https://deb.nodesource.com/setup_${NODEJS_MAJOR}.x` (deleted after). COPY `build-ztncui.sh`, runs it -> `/build/artifact.zip`.
- `gobuilder`: `FROM golang:bullseye`. ENV `CGO_ENABLED=0`. WORKDIR `/buildsrc`. COPY `argon2g`, `fileserv`, `ztnodeid`, `build-gobinaries.sh`. apt: zip. Runs build -> `artifact-go.zip`.
- `runner`: `FROM debian:bullseye-slim`. ENV `DEBIAN_FRONTEND=noninteractive`, `AUTOGEN_PLANET=0`. ARG `OVERLAY_S6_ARCH`.

## Runner details
- apt: curl gnupg2 ca-certificates gzip xz-utils iproute2 unzip net-tools procps.
- s6-overlay v3.1.3.0: `s6-overlay-noarch.tar.xz` and `s6-overlay-$OVERLAY_S6_ARCH.tar.xz` from github just-containers, extracted to `/`.
- Group/user `zerotier-one` GID/UID 2222; `zerotier-one` and `root` in that group.
- Runs `https://install.zerotier.com` script (deleted after).
- Cleanup removes `/var/lib/zerotier-one` and apt lists.
- COPY `artifact.zip` -> `/opt/key-networks/ztncui/` (unzipped). COPY `start_firsttime_init.sh start_zt1.sh start_ztncui.sh` -> `/`. `artifact-go.zip` unzipped to `/usr/local/bin`. COPY `s6-rc.d/` -> `/etc/s6-overlay/s6-rc.d/`.
- EXPOSE 3000/tcp, 3180/tcp, 8000/tcp, 3443/tcp.
- VOLUME `/opt/key-networks/ztncui/etc`, `/etc/zt-mkworld`, `/var/lib/zerotier-one`.
- ENTRYPOINT `["/init"]`. No CMD, USER, HEALTHCHECK.

## Gotchas
- Two debian:bullseye base stages; nodesource and zerotier install scripts fetched at build time (unpinned URLs).
- Runs as root by design (s6 init).
