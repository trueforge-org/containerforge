# xthursdayx/gpodder-docker: Dockerfile (commit 2c723a12)

Source URL(s): https://raw.githubusercontent.com/xthursdayx/gpodder-docker/2c723a12db40b1ab9ab2cde0b6b298932c245321/Dockerfile (fetched 2026-11-27; blob/ variant is the same file)

## Build (2 stages, both FROM ghcr.io/linuxserver/baseimage-selkies:alpine324)
- Stage `build`: ARG GPODDER_VERSION=3.11.5. apk add gettext intltool make py3-build py3-installer py3-setuptools py3-wheel.
- Downloads https://github.com/gpodder/gpodder/archive/refs/tags/${GPODDER_VERSION}.tar.gz to /src; `make -C /src install PYTHON=/usr/bin/python3 PREFIX=/usr DESTDIR=/out`.
- Creates /out/usr/share/gpodder/no-update-check (disables in-app update check).
- Downloads web client icon to /out/usr/share/selkies/www/icon.png from raw.githubusercontent.com/xthursdayx/docker-templates (third-party URL, not in urls.txt).
- Runtime stage: apk add adwaita-icon-theme eyed3 ffmpeg mutagen py3-cairo py3-dbus py3-gobject3 py3-html5lib py3-mygpoclient py3-pillow py3-podcastparser py3-pysocks py3-requests webkit2gtk-4.1 xdg-utils yt-dlp; rm -rf /tmp/*.
- COPY --from=build /out/ /; COPY root/ /.
- ARG GPODDER_THEME=light; ENV GPODDER_THEME.
- Labels: build_version, maintainer xthursdayx.

## Env (Dockerfile)
| Name | Value |
| --- | --- |
| TITLE | gPodder |
| LANG | en_US.UTF-8 |
| GPODDER_HOME | /config |
| GPODDER_DOWNLOAD_DIR | /downloads |
| GPODDER_THEME | light (build arg; "dark" tag built with GPODDER_THEME=dark) |

## Ports / volumes
- EXPOSE 3000 3001. VOLUME ["/config", "/downloads"].

## Entrypoint / user
- Not set in Dockerfile; inherited from linuxserver baseimage-selkies (s6-overlay init; root/ service scripts not fetched).

## Runtime deps
- Alpine 3.24 packages listed above; gtk3, fonts, dbus, openbox/labwc, xdg-open come from base image.

## Version/asset naming
- Upstream tarball tag: 3.11.5 (GitHub archive tag). Install via make install (PREFIX=/usr).

## Gotchas
- Build needs network (GitHub tarball and docker-templates icon).
- Config files kept at /config for compatibility (GPODDER_HOME).
- root/ overlay directory not fetched (service/init files live there).
