# GitHub: portainer/portainer

## Source URL(s) + date
- https://api.github.com/repos/portainer/portainer/releases/latest
- https://raw.githubusercontent.com/portainer/portainer/505380c8eecff08cf513c457494bde91634db9ff/build/linux/Dockerfile
- Fetched 2026-11-27

## Latest release
- tag `2.45.4` (no `v` prefix), name "Release 2.45.4 LTS", published 2026-11-18T20:13:36Z.
- 14 assets, per arch and Windows:
  - `portainer-2.45.4-linux-{amd64,arm,arm64,ppc64le}.tar.gz`, each with `-checksum.txt`.
  - `portainer-2.45.4-windows1809-amd64.tar.gz` and `windowsltsc2022-amd64`, `windowsltsc2025-amd64`, each with `-checksum.txt`.
- Download pattern: `portainer-${VERSION}-linux-${ARCH}.tar.gz`; checksum file `portainer-${VERSION}-linux-${ARCH}-checksum.txt`.

## Upstream Dockerfile (build/linux/Dockerfile, commit 505380c8)
- Single stage `FROM portainer/base AS production`.
- `WORKDIR /`.
- No RUN.
- `COPY dist/mustache-templates /mustache-templates/`; `COPY dist/portainer /`; `COPY dist/public /public/`; `COPY build/docker-extension /`; `COPY dist/storybook* /storybook/` (portainerci builds only).
- `EXPOSE 9000`, `EXPOSE 9443`, `EXPOSE 8000`.
- `VOLUME /data`.
- `ENTRYPOINT ["/portainer"]`; no CMD.
- ARG `GIT_COMMIT=unspecified`, `BUILD_DATE=unspecified`; LABELs for Docker Desktop extension metadata and `io.portainer.server="true"`.
- No ENV, USER.

## Ports
- 9000 (HTTP UI), 9443 (HTTPS UI), 8000 (edge tunnel).

## Volumes/paths
- `/data` (upstream VOLUME); binary at `/portainer`; UI at `/public`; templates at `/mustache-templates`.

## User/UID
- Not set (runs as root by base image default).

## Gotchas
- Upstream base image `portainer/base` is not reproduced here; tarball build is the source for ContainerForge.
- LICENSE not included in this fetch (repo LICENSE not read).
