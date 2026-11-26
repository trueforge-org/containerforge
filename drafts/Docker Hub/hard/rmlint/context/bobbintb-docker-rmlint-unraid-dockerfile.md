# bobbintb/docker-rmlint-unraid Dockerfile (commit e0f6d3c0)

Source: https://github.com/bobbintb/docker-rmlint-unraid/blob/e0f6d3c0a2a98751545a5bce577b4703c056286e/Dockerfile (raw, pinned commit), fetched 2026-11-26. Full file read.

## Build
- Base: `FROM ghcr.io/linuxserver/baseimage-selkies:ubuntunoble` (Ubuntu 24.04 noble, Selkies GUI base).
- ARGs: BUILD_DATE, VERSION, RMLINT_VERSION (RMLINT_VERSION declared but unused).
- apt (--no-install-recommends): wget jq python3-gi gir1.2-gtk-3.0 gir1.2-rsvg-2.0 librsvg2-common gir1.2-gtksource-4 python3-cairo python3-gi-cairo.
- rmlint install: `latest_tag=$(curl -s https://api.github.com/repos/bobbintb/docker-rmlint-unraid/releases/latest | jq -r .tag_name)`; `wget https://github.com/bobbintb/docker-rmlint-unraid/releases/latest/download/rmlint_${latest_tag#v}_amd64.deb`; `apt install ./rmlint*.deb`.
- Openbox tweak: `sed -i 's/NLIMC/NLMC/g' /etc/xdg/openbox/rc.xml`.
- `/build_version` written from VERSION and BUILD_DATE.
- Cleanup: rm /config/.cache, /config/.launchpadlib, apt lists, /var/tmp/*, /tmp/*.
- `COPY /root /` (local s6 service files; not in this repo file).

## Runtime
- No ENTRYPOINT/CMD (inherits base image init).
- `EXPOSE 8321 8322`; `VOLUME /config`.

## Env
| Var | Value |
| --- | --- |
| TITLE | rmlint |
| NO_GAMEPAD | true |
| CUSTOM_PORT | 8321 (HTTP, Guacamole/Selkies web UI) |
| CUSTOM_HTTPS_PORT | 8322 |
| LABEL build_version | "Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}" |

## Ports
- 8321/tcp HTTP, 8322/tcp HTTPS (web desktop).

## Volumes/paths
- /config (VOLUME). Chart also mounts /root as search location.

## Version/asset naming
- Package `rmlint_<tag without v>_amd64.deb` from the latest GitHub release of bobbintb/docker-rmlint-unraid (unpinned at build time).
- Version resolved via API releases/latest (unauthenticated).

## Arch
- amd64 only (asset name hard-coded `_amd64.deb`).

## Gotchas
- Build-time "latest" lookup: not reproducible.
- Hub text says rmlint is compiled from source; the Dockerfile installs a prebuilt .deb from the fork's releases instead.
- No USER/UID set here; base image handles PUID/PGID (LinuxServer convention, not in this file).
