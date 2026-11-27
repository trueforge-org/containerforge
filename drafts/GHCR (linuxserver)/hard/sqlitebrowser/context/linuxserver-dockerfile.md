# linuxserver/docker-sqlitebrowser Dockerfile
Source: https://raw.githubusercontent.com/linuxserver/docker-sqlitebrowser/07d24df2caea/Dockerfile (fetched 2026-11-27)

## Build
- Single stage, FROM ghcr.io/linuxserver/baseimage-rdesktop-web:bionic
- ARG BUILD_DATE, VERSION, SQLITEB_VERSION (no defaults)
- ENV: none
- LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}", maintainer="aptalca"

## Install steps (single RUN)
1. apt-get update; apt-get install -y gnupg
2. apt-key adv --keyserver hkp://keyserver.ubuntu.com:11371 --recv-keys 941353830DA80B6A06276736B0C3F48A7F2583EA
3. Append to /etc/apt/sources.list.d/sqlitebrowser.list:
   - deb http://ppa.launchpad.net/linuxgndu/sqlitebrowser/ubuntu bionic main
   - deb-src http://ppa.launchpad.net/linuxgndu/sqlitebrowser/ubuntu bionic main
4. If SQLITEB_VERSION unset: read PPA bionic/main/binary-amd64 Packages.gz, grep first "Package: sqlitebrowser" (-A 7 -m 1), awk Version field
5. apt-get update; apt-get install -y sqlitebrowser=${SQLITEB_VERSION}
6. apt-get clean; rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

## Packages
- gnupg, sqlitebrowser (PPA, pinned to SQLITEB_VERSION)

## Other
- COPY /root /
- EXPOSE 3000
- VOLUME /config
- USER: none set (inherits base)
- ENTRYPOINT/CMD: none (inherits base)
- HEALTHCHECK: none

## Gotchas
- Ubuntu bionic PPA on an rdesktop base; version is auto-detected from PPA unless build arg given.
- Package comes from a third-party PPA (linuxgndu), not upstream release assets.
