# linuxserver/docker-blender @ 16e1a2aec1d331f2a4462eb52538b99d6d1c2932

Source URL(s): https://raw.githubusercontent.com/linuxserver/docker-blender/16e1a2aec1d331f2a4462eb52538b99d6d1c2932/Dockerfile ; .../root/defaults/autostart (fetched 2026-11-27). root/etc/s6-overlay svc run path returned 404 (not retried).

## What it is
- Blender 3D in a browser-streamed desktop (Selkies), linuxserver.io image.

## Build
- `FROM ghcr.io/linuxserver/baseimage-selkies:ubunturesolute`.
- ARG BUILD_DATE, VERSION, BLENDER_VERSION (optional).
- ENV TITLE=Blender, NO_GAMEPAD=true, PIXELFLUX_WAYLAND=true.
- Icon downloaded to /usr/share/selkies/www/icon.png (from linuxserver docker-templates).
- apt: ocl-icd-libopencl1, xz-utils; symlink libOpenCL.so.1 -> libOpenCL.so.
- Version: if BLENDER_VERSION unset, query projects.blender.org tags API (non-rc, highest sorted, strip leading v).
- Folder = Blender<major.minor> from version (sed).
- Download `https://mirror.clarkson.edu/blender/release/${BLENDER_FOLDER}/blender-${BLENDER_VERSION}-linux-x64.tar.xz`; fallback `https://mirrors.iu13.net/...`.
- tar xf -> /blender (strip 1); symlink /usr/bin/blender -> /blender/blender.
- /build_version file; cleanup /tmp, apt lists.
- COPY /root / (s6 service files, not fetched except defaults/autostart).

## Entrypoint
- Selkies base s6 init (not fetched). Autostart: `root/defaults/autostart` = `blender --python-expr "import bpy; bpy.context.preferences.inputs.use_mouse_continuous = False"`.

## Ports
- EXPOSE 3001 (Dockerfile). Chart uses 3000.

## Volumes
- VOLUME /config.

## User/UID
- Selkies base model (root s6 image; not verified here).

## Arch
- amd64 only: tarball is linux-x64 and the Blender path is x64.

## Gotchas
- Tarball mirrors are not official download.blender.org (plan uses download.blender.org).
- Requires s6/Selkies base: conflicts with `USER apps` and read-only rootfs per plan.
- Version pick is by API at build time when BLENDER_VERSION unset; pin BLENDER_VERSION for reproducibility.
