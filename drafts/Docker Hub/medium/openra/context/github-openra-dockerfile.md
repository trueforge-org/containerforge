# GitHub: rmoriz/openra-dockerfile Dockerfile (pinned commit 62aa1508bb9c3df1ab41b9e20252880ac6823fcc)
Source URL(s): https://raw.githubusercontent.com/rmoriz/openra-dockerfile/62aa1508bb9c3df1ab41b9e20252880ac6823fcc/Dockerfile (fetched 2026-11-27)

## Build
- ARG BASE_IMAGE_PREFIX; FROM ${BASE_IMAGE_PREFIX}mono
- ARG ARCH; COPY .gitignore qemu-${ARCH}-static* /usr/bin/ (qemu hack for multiarch)
- ARG OPENRA_RELEASE_VERSION=20231010, OPENRA_RELEASE_TYPE=release, OPENRA_RELEASE (default URL: OpenRA GitHub release source tar.bz2)
- apt install: ca-certificates curl liblua5.1 libsdl2-2.0-0 libopenal1 make patch unzip xdg-utils zenity wget
- useradd -d /home/openra -m -s /sbin/nologin openra
- curl -L $OPENRA_RELEASE | tar xj in /home/openra/source; `make all RUNTIME=mono`
- mv source -> /home/openra/lib/openra
- mkdir /home/openra/.openra{,/Logs,/maps}, chown openra
- apt purge curl make patch unzip; rm apt lists

## Runtime
- EXPOSE 1234
- USER openra
- WORKDIR /home/openra/lib/openra
- VOLUME ["/home/openra/.openra"]
- CMD ["/home/openra/lib/openra/launch-dedicated.sh"]
- LABEL licenses GPL-3.0, authors Roland Moriz

## Gotchas
- Pinned to OpenRA release-20231010 by default; build args override
- Comment: geoip-based player IP disclosure removed upstream (use Server.ShareAnonymizedIPs)
