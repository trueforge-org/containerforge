# Upstream Dockerfile: linuxserver/docker-orcaslicer

Source URL(s):
- https://raw.githubusercontent.com/linuxserver/docker-orcaslicer/4b114d95b04b/Dockerfile
- Blob variant: https://github.com/linuxserver/docker-orcaslicer/blob/4b114d95b04b/Dockerfile
- Fetched 2026-11-27

## What it is
Single-stage Dockerfile on the Selkies base (Debian trixie). Installs Firefox and GUI libs from apt, plus the OrcaSlicer AppImage extracted to `/opt/orcaslicer`.

## Base
- `FROM ghcr.io/linuxserver/baseimage-selkies:debiantrixie`

## Args / labels / env
- ARGs: `BUILD_DATE`, `VERSION`, `ORCASLICER_VERSION` (if unset, resolved from GitHub API latest tag).
- LABEL build_version, maintainer thelamer.
- `ENV TITLE=OrcaSlicer SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt PIXELFLUX_WAYLAND=true`

## Install steps (RUN, one layer)
1. Icon: curl `orcaslicer-logo.png` from linuxserver docker-templates to `/usr/share/selkies/www/icon.png`.
2. Mozilla apt repo: key `https://packages.mozilla.org/apt/repo-signing-key.gpg` to `/etc/apt/keyrings/packages.mozilla.org.asc`; list `deb [signed-by=...] https://packages.mozilla.org/apt mozilla main`; apt pin origin packages.mozilla.org priority 1000.
3. apt install (no recommends): `firefox`, gstreamer1.0-{alsa,gl,gtk3,libav,plugins-bad,plugins-base,plugins-good,plugins-ugly,pulseaudio,qt5,tools,x}, `libgstreamer-plugins-bad1.0`, `libmspack0`, `libwebkit2gtk-4.1-0`, `libwx-perl`.
4. AppImage: version from `https://api.github.com/repos/OrcaSlicer/OrcaSlicer/releases/latest` (`.tag_name`) if `ORCASLICER_VERSION` unset. Asset = first `browser_download_url` matching `Ubuntu2404_V` (via release `.url`, jq).
5. `cd /tmp`, download to `/tmp/orca.app`, `chmod +x`, `./orca.app --appimage-extract`, `mv squashfs-root /opt/orcaslicer`.
6. `localedef -i en_GB -f UTF-8 en_GB.UTF-8`; `chmod +x /opt/orcaslicer/libexec/orca-slicer-env`; `sed -i "1a export GDK_BACKEND=x11" /opt/orcaslicer/AppRun`; dirs chmod 755.
7. Writes `/build_version`. Cleanup: apt-autoclean, rm `/config/.cache`, `/config/.launchpadlib`, `/var/lib/apt/lists/*`, `/var/tmp/*`, `/tmp/*`.

## Runtime
- `COPY /root /` (s6 files, not fetched).
- `EXPOSE 3001`
- `VOLUME /config`
- No USER, ENTRYPOINT or CMD in this file.

## Version/asset naming
- Git tag `vX.Y.Z`, asset `OrcaSlicer_Linux_AppImage_Ubuntu2404_V<X.Y.Z>.AppImage` (amd64) and `..._Ubuntu2404_aarch64_V<X.Y.Z>.AppImage` (arm64). See orcaslicer-github-latest.md.

## Gotchas
- AppImage is built for Ubuntu 24.04; upstream runs it extracted, so no FUSE needed.
- `GDK_BACKEND=x11` is forced via AppRun sed.
