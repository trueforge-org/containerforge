# GitHub: ngosang/docker-amule Dockerfile @ 3.2.0-1 (upstream image source)

## Source URL(s) + date
- https://raw.githubusercontent.com/ngosang/docker-amule/3.2.0-1/Dockerfile (2026-11-27)
- Blob URL in urls.txt (github.com/ngosang/docker-amule/blob/3.2.0-1/Dockerfile) is the same file.
- Not fetched: https://api.github.com/repos/ngosang/docker-amule/releases/latest (HTTP 403 rate limit).
- Not fetched: https://github.com/ngosang/docker-amule (repo root).

## What it is
Multi-stage build of the aMule daemon, web UI and tools for `ghcr.io/ngosang/amule`.

## Build stage (`debian:trixie-slim` AS builder)
- apt: build-essential cmake make git binutils-dev ca-certificates pkg-config python3 libatomic1 libboost-dev libcrypto++-dev libmaxminddb-dev libreadline-dev libcurl4-openssl-dev libpcre2-dev zlib1g-dev libpng-dev libupnp-dev.
- `ARG FFMPEG_REF=n9.0.1`: minimal ffprobe (demuxers, parsers, file protocol only; network, programs, avdevice, avfilter, swscale, swresample disabled).
- `ARG WX_REF=v3.2.12`: wxBase and wxNet only, `--disable-gui`, `--with-libcurl` (mandatory). Built from source because amuled hits a use-after-free in the wx event loop during startup HTTP downloads; the fix is in wx 3.2.12 (Debian trixie has 3.2.8). Upstream issue amule-org/amule#1136.
- `ARG AMULE_REF=3.2.0`: built with CMake: `BUILD_DAEMON=YES`, `BUILD_AMULECMD=YES`, `BUILD_WEBSERVER=YES`, `BUILD_AMULEAPI=YES`, `BUILD_ALCC=YES`, `ENABLE_IP2COUNTRY=YES`, `ENABLE_UPNP=YES`, `ENABLE_NLS=NO`, `BUILD_MONOLITHIC=NO`, `BUILD_TESTING=NO`, Release.
- AMULE_REF may be a tag, branch or commit.

## Runtime stage (`debian:trixie-slim`)
- Copies from builder: `/usr/bin/{alcc,amuleapi,amulecmd,amuled,amuleweb,ed2k,ffprobe}`, `/usr/share/amule`, `libwx_baseu*.so.0.*.*`.
- apt runtime: libcrypto++8t64 libreadline8t64 libgcc-s1 libstdc++6 libpng16-16t64 libpcre2-32-0 libupnp17t64 libmaxminddb0 libatomic1 libbinutils ca-certificates curl tzdata procps pwgen s6 cron systemd-standalone-sysusers.
- Build check: `ldd` on each binary, fail build on "not found".
- `ENV LANG=C.UTF-8 LC_ALL=C.UTF-8`.
- `COPY --chmod=755 docker/entrypoint.sh docker/amule-config.sh docker/amule-mods.sh /home/amule/`
- `COPY --chmod=755 docker/services.d/ /etc/services.d/` (s6 services).
- `WORKDIR /home/amule`.
- `EXPOSE 4711/tcp 4712/tcp 4662/tcp 4665/udp 4672/udp`.
- `ENTRYPOINT ["/home/amule/entrypoint.sh"]`.
- No USER, VOLUME or CMD in this file.

## Ports
- 4711/tcp (web), 4712/tcp (remote GUI), 4662/tcp (ed2k), 4665/udp, 4672/udp.

## Gotchas
- Entrypoint and s6 scripts (`docker/*.sh`, `docker/services.d/`) are referenced but not fetched in this run; env var names beyond chart's `WEBUI_PWD`/`GUI_PWD` remain unverified.
- Maintainer label: ngosang (upstream).
- Multi-arch build recipe in comments: 386, amd64, arm/v5, arm/v7, arm64/v8, ppc64le, riscv64, s390x.
