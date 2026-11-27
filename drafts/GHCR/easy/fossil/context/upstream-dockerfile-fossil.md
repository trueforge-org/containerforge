# Upstream Dockerfile and s6 scripts: nicholaswilde/docker-fossil

Source URL(s):
- https://raw.githubusercontent.com/nicholaswilde/docker-fossil/ca99797/Dockerfile (fetched 2026-11-27, pinned commit; blob URL is the same file)
- https://raw.githubusercontent.com/nicholaswilde/docker-fossil/ca99797/root/etc/cont-init.d/30-config (fetched)
- https://raw.githubusercontent.com/nicholaswilde/docker-fossil/ca99797/root/etc/services.d/fossil/run (fetched)

## What it is
- Two-stage build: compile Fossil from source in Alpine 3.13.5, then copy the binary into a LinuxServer s6 base image.

## Build steps (stage 1, `FROM alpine:3.13.5 as base`)
- apk (pinned): `libressl-dev=3.1.5-r0 sqlite-dev=3.34.1-r0 tcl-dev=8.6.10-r1 zlib-dev=1.2.11-r3 curl=7.77.0-r0 alpine-sdk=1.0-r0`.
- Downloads `https://www.fossil-scm.org/home/uv/fossil-src-${VERSION}.tar.gz`, verifies `${CHECKSUM}` with sha256sum.
- `./configure --disable-fusefs --json --with-th1-docs --with-th1-hooks --with-tcl-private-stubs=1 --with-tcl=1`, then `make`, `strip fossil`.

## Build steps (stage 2, `ghcr.io/linuxserver/baseimage-alpine:3.13`)
- `ENV HOME /app`, `COPY --from=base /fossil /usr/bin/`.
- apk: `libressl=3.1.5-r0 tcl=8.6.10-r1`.
- `chown -R abc:abc /app`, `rm -rf /tmp/*`.
- `COPY root/ /` (s6 overlay scripts).
- `EXPOSE 8080`, `VOLUME /app`.
- Labels: `build_version`, `maintainer="nicholaswilde"`.

## Entrypoint (s6)
- `root/etc/cont-init.d/30-config`: `chown -R abc:abc /app`.
- `root/etc/services.d/fossil/run`: `cd /app`, then `exec s6-setuidgid abc /usr/bin/fossil server --create --user admin /app/repository.fossil`.
- The run script passes no `--port`; the listen port is not set in the fetched files (container EXPOSE is 8080).

## Runtime deps
- libressl, tcl (runtime). Alpine/musl base.

## Env vars
| Name | Value |
| --- | --- |
| HOME | /app |

## Ports
- EXPOSE 8080.

## Volumes/paths
- `/app` (VOLUME). Repository file `/app/repository.fossil`.

## User/UID
- Services run as `abc` (LinuxServer s6 user) via `s6-setuidgid`.

## Version
- Build arg `VERSION` and `CHECKSUM` supplied at build time; chart tag `2.15.1-ls4`.

## Gotchas
- Stage 2 is Alpine (musl). ContainerForge needs a glibc Ubuntu base.
- `fossil server --create` creates the repo on first run.
