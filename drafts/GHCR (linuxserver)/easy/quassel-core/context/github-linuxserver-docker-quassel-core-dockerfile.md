# linuxserver/docker-quassel-core Dockerfile (pinned c995ed5491d2)

Source URL(s) + date: https://raw.githubusercontent.com/linuxserver/docker-quassel-core/c995ed5491d2/Dockerfile (blob URL = same file), fetched 2026-11-27

## What it is
Multi-stage build of Quassel core (no client) from source tarball, on linuxserver Alpine base.

## Base
- Build stage: `FROM ghcr.io/linuxserver/baseimage-alpine:3.20 AS build-stage`
- Runtime: `FROM ghcr.io/linuxserver/baseimage-alpine:3.20`
- Labels: build_version; maintainer "chbmb".

## Build args / env
- ARG CXXFLAGS (hardening: -D_FORTIFY_SOURCE=2, -fstack-protector-strong, -fPIE -pie, relro/now, noexecstack) — declared, not passed to cmake explicitly.
- ARG QUASSEL_RELEASE (optional; if unset, from `api.github.com/repos/quassel/quassel/releases/latest` `.tag_name` via jq).
- ARG BUILD_DATE, VERSION.
- ENV HOME=/config (runtime).

## Install steps
1. Build stage apk: boost-dev build-base cmake dbus-dev icu-dev openssl-dev openldap-dev qt5-qtbase-dev qt5-qtscript-dev qt5-qtbase-postgresql qt5-qtbase-sqlite qca-dev zlib-dev
2. Fetch `https://github.com/quassel/quassel/archive/${QUASSEL_RELEASE}.tar.gz` -> /tmp/quassel-src (strip 1).
3. cmake: `-DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr -DWANT_CORE=ON -DWANT_MONO=OFF -DWANT_QTCLIENT=OFF -DWITH_KDE=OFF`; `make -j2`; `make DESTDIR=/build/quassel install`.
4. Runtime apk: icu-libs openssl qt5-qtbase qt5-qtbase-postgresql qt5-qtbase-sqlite qt5-qtscript libqca-qt5 openldap.
5. Writes `/build_version`.
6. `COPY --from=build-stage /build/quassel/usr/ /usr/`; `COPY root/ /`.

## Entrypoint/flags
- No ENTRYPOINT/CMD here (s6 base). Runtime flags come from RUN_OPTS env in linuxserver init (see README).

## Ports
- `EXPOSE 4242 10113`

## Volumes/paths
- `VOLUME /config`; `HOME=/config`.

## Config files
- `root/` overlay (not fetched).

## Version/asset naming
- Source: `quassel-${QUASSEL_RELEASE}.tar.gz` from GitHub archive tag (`0.14.0`).
- Upstream release assets also include `quassel-0.14.0.tar.xz` and `.sha256sum`.

## Arch
- Built on baseimage-alpine for amd64 and arm64 (per Hub tags).

## Gotchas
- Build stage fetches latest release when QUASSEL_RELEASE unset: unpinned path.
