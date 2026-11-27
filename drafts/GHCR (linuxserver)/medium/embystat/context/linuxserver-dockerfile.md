# linuxserver/docker-embystat Dockerfile
Source: https://raw.githubusercontent.com/linuxserver/docker-embystat/5fa06c158344aeefbec98e0e211b34198f4f2063/Dockerfile (fetched 2026-11-27)

## Build
- Single stage FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy
- ARG BUILD_DATE, VERSION, EMBYSTAT_RELEASE
- ENV HOME=/config
- LABEL build_version (Linuxserver.io version VERSION, Build-date), maintainer="aptalca"

## Install (single RUN)
1. apt-get update; apt-get install -y libicu70 libssl3 unzip (no pins)
2. mkdir -p /opt/embystat
3. If EMBYSTAT_RELEASE unset: first tag_name from https://api.github.com/repos/mregni/EmbyStat/releases (jq first)
4. curl -o /tmp/embystat.zip -L https://github.com/mregni/EmbyStat/releases/download/${EMBYSTAT_RELEASE}/EmbyStat-ubuntu-x64-v${EMBYSTAT_RELEASE}.zip
5. unzip /tmp/embystat.zip -d /opt/embystat/ (stderr suppressed, failures ignored)
6. chmod +x /opt/embystat/EmbyStat
7. rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

## Other
- COPY /root /
- EXPOSE 6555
- VOLUME, USER, ENTRYPOINT, CMD, HEALTHCHECK, ADD: none (base init presumed)

## Version/asset naming
- Asset: EmbyStat-ubuntu-x64-v<TAG>.zip, TAG = release tag (e.g. 0.2.0-beta.30 -> EmbyStat-ubuntu-x64-v0.2.0-beta.30.zip)
- Binary: /opt/embystat/EmbyStat

## Gotchas
- unzip failure is silently ignored (|| true, stderr to /dev/null)
- Arch: only ubuntu-x64 asset is referenced; no arm64 path in Dockerfile
