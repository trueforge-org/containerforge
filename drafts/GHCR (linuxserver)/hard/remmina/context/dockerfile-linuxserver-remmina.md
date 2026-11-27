# Upstream Dockerfile: linuxserver/docker-remmina

Source URL(s):
- https://raw.githubusercontent.com/linuxserver/docker-remmina/9c34e90f8d44/Dockerfile
- Blob variant: https://github.com/linuxserver/docker-remmina/blob/9c34e90f8d44/Dockerfile
- Fetched 2026-11-27

## What it is
Single-stage Dockerfile on the Selkies desktop-streaming base (Ubuntu resolute). Installs Remmina from the Ubuntu archive via apt.

## Base
- `FROM ghcr.io/linuxserver/baseimage-selkies:ubunturesolute`

## Args / labels / env
- ARGs: `BUILD_DATE`, `VERSION`, `REMMINA_RELEASE` (optional apt version pin, used as `remmina=<ver>` when set).
- LABEL build_version, maintainer thelamer.
- `ENV TITLE=Remmina PIXELFLUX_WAYLAND=true`

## Install steps (RUN, one layer)
1. Icon: curl `remmina-logo.png` from linuxserver docker-templates to `/usr/share/selkies/www/icon.png`.
2. `apt-get update`
3. `apt-get install -y librsvg2-common "remmina[=$REMMINA_RELEASE]" remmina-plugin-exec remmina-plugin-kiosk remmina-plugin-kwallet remmina-plugin-rdp remmina-plugin-secret remmina-plugin-spice remmina-plugin-vnc remmina-plugin-www remmina-plugin-x2go`
4. Writes `/build_version`.
5. Cleanup: `apt-get clean`, rm `/tmp/*`, `/var/lib/apt/lists/*`, `/var/tmp/*`.

## Runtime
- `COPY /root /` (s6 files, not fetched).
- `EXPOSE 3001`
- `VOLUME /config`
- No USER, ENTRYPOINT or CMD in this file.

## Gotchas
- Upstream does not install a headless mode; the Selkies base supplies the display and web UI.
- Plugin set (rdp, vnc, spice, x2go, www, exec, kiosk, kwallet, secret) is upstream's full set.
