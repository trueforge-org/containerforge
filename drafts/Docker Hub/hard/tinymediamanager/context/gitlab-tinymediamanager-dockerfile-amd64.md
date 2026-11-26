# tinyMediaManager Dockerfile.amd64 (upstream, at commit a2204fc)

**Source URL(s):** https://gitlab.com/tinyMediaManager/tinyMediaManager/-/blob/a2204fc/src/docker/Dockerfile.amd64 (fetched via https://gitlab.com/tinyMediaManager/tinyMediaManager/-/raw/a2204fc/src/docker/Dockerfile.amd64)
**Fetched:** 2026-11-26

## Base
- `FROM tinymediamanager/base-amd64:20260510065355` (a jlesage-style GUI base, Debian-based; x86_64 only).

## ENV
- `APP=tinyMediaManager`
- `ALLOW_DIRECT_VNC=true`
- `LANG=en_US.UTF-8`, `LC_ALL=en_US.UTF-8`, `LC_TIME=C.UTF-8`

## Build args / packages
- `LIBZEN=https://mediaarea.net/download/binary/libzen0/0.4.41/libzen0v5_0.4.41-1_amd64.Debian_13.deb`
- `LIBMEDIAINFO=https://mediaarea.net/download/binary/libmediainfo0/26.10/libmediainfo0v5_26.10-1_amd64.Debian_13.deb`
- One RUN: download both .deb with wget, `dpkg -i` both, delete the .deb files. No apt-get install.

## Labels
- OCI labels from build placeholders (version, title, description, URL, revision).
- License: "Apache License, Version 2.0".
- Documentation: https://www.tinymediamanager.org/docs/docker
- Source label from scm URL placeholder (trailing space in key).

## Application layout
- `ADD` the local `tinyMediaManager` directory to `/app`; `WORKDIR /app`.

## Startup
- `CMD ["/app/tinyMediaManager", "-Dtmm.contentfolder=/data"]`. The only -D property passed.

## Not present
EXPOSE, VOLUME, USER, COPY, ENTRYPOINT.

## Gotchas for our build
- Upstream uses Debian 13 .debs from mediaarea.net, not Ubuntu packages. plan.md's Ubuntu `libmediainfo0v5` plan would need verifying.
- The upstream image is amd64-only; the .deb URLs are amd64.
- Upstream runs the app directly with CMD, no start script.
