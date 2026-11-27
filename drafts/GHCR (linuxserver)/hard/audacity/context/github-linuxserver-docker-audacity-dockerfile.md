# linuxserver/docker-audacity Dockerfile: master (current) and pinned b0c6f0d

Source URL(s) + date: https://raw.githubusercontent.com/linuxserver/docker-audacity/master/Dockerfile (fetched 2026-11-27); https://raw.githubusercontent.com/linuxserver/docker-audacity/b0c6f0d2e0d8650f40ef6e5a8661baa2230a5812/Dockerfile (blob URL = same file; fetched 2026-11-27).

## MASTER (current; the plan's reference)
- `FROM ghcr.io/linuxserver/baseimage-selkies:ubunturesolute` (single stage).
- ARG: BUILD_DATE, VERSION, AUDACITY_VERSION (optional).
- Labels: build_version; maintainer aptalca.
- ENV: `TITLE=Audacity`, `NO_GAMEPAD=true`, `PIXELFLUX_WAYLAND=true`.
- Icon: curl `audacity-logo.png` from linuxserver docker-templates to `/usr/share/selkies/www/icon.png`.
- apt install: python3-xdg, libatk1.0, libatk-bridge2.0, libnss3, libportaudio2.
- AUDACITY_VERSION if unset: `api.github.com/repos/audacity/audacity/releases/latest` `.tag_name` with `Audacity-` stripped.
- Download: `https://github.com/audacity/audacity/releases/download/Audacity-${AUDACITY_VERSION}/audacity-linux-${AUDACITY_VERSION}-x86_64.AppImage` -> /tmp/audacity.app (x86_64 only).
- `./audacity.app --appimage-extract` -> `/opt/audacity` (squashfs-root); chmod dirs 755.
- Symlink `/usr/lib/x86_64-linux-gnu/libportaudio.so.2` -> `libportaudio.so`.
- Writes `/build_version`; cleanup /tmp/*, apt lists.
- `COPY /root /`
- `EXPOSE 3001`; `VOLUME /config`.
- No USER, ENTRYPOINT or CMD in Dockerfile.

## PINNED b0c6f0d2 (older, for comparison)
- `FROM ghcr.io/linuxserver/baseimage-rdesktop-web:focal` (2-stage build from source: cmake, wxWidgets local, ffmpeg loaded, `audacity-minsrc-${VERSION}.tar.xz`).
- Runtime: `EXPOSE 3000`; `VOLUME /config`; maintainer aptalca.
- Do not use as build reference: superseded by master (different base, EXPOSE and build method).

## Version/asset naming
- Tag: `Audacity-<ver>` (e.g. `Audacity-4.0.2`); strip prefix for VERSION.
- Asset: `audacity-linux-<ver>-x86_64.AppImage` (and `-aarch64.AppImage`).

## Arch
- Upstream linuxserver fetches x86_64 only.
