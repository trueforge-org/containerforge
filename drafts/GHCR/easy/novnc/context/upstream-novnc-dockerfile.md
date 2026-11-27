# novnc upstream Dockerfile (nicholaswilde/docker-novnc @ caa724f), noVNC release, websockify, license

Source URL(s) + date: https://raw.githubusercontent.com/nicholaswilde/docker-novnc/caa724f/Dockerfile ; https://github.com/novnc/noVNC/releases/latest (HTML alternative) ; https://pypi.org/pypi/websockify/json ; https://raw.githubusercontent.com/novnc/noVNC/v1.7.0/LICENSE.txt (fetched 2026-11-27)

## Stages
| Stage | Base | Notes |
| --- | --- | --- |
| 1 (alias base) | ghcr.io/linuxserver/baseimage-alpine:3.14 | ARG VERSION=1.2.0, WEBSOCKIFY_VERSION=0.9.0; apk git=2.32.0-r0, curl=7.77.0-r1 (--no-cache); `git clone noVNC -b v${VERSION} --depth=1`; `git clone websockify -b v${WEBSOCKIFY_VERSION} --depth=1 /noVNC/utils/websockify`; fetches curl cacert.pem to /noVNC/self.pem; rm -rf /tmp/* |
| 2 (final) | ghcr.io/linuxserver/baseimage-alpine:3.14 | WORKDIR /app; COPY --from=base /noVNC . ; SHELL /bin/ash -eo pipefail -c |

- Stage 2 apk: appends `@community https://dl-cdn.alpinelinux.org/alpine/v3.9/community/` to repositories; installs ca-certificates=20191127-r5, python3=3.9.5-r1, python2=2.7.18-r2, py2-numpy@community=1.15.4-r0 (--no-cache); `chown -R abc:abc /app`; rm -rf /tmp/*.
- ARG (stage 2): BUILD_DATE, VERSION (no defaults). LABEL build_version, maintainer nicholaswilde.

## Runtime
| Item | Value |
| --- | --- |
| ENV | REMOTE_HOST=localhost; REMOTE_PORT=5900 |
| EXPOSE | 6080 |
| VOLUME | /app |
| USER | not set; /app owned by abc:abc (linuxserver convention; no UID/GID stated) |
| ENTRYPOINT | not set |
| CMD | ["sh", "-c", "./utils/launch.sh --vnc ${REMOTE_HOST}:${REMOTE_PORT}"] |
| HEALTHCHECK | not set |

## Versions
- noVNC latest release: v1.7.0 (GitHub HTML page, commit 63107bd, date "28 Apr", year not shown). API releases/latest returned 403 (not retried). Asset names not loaded.
- websockify on PyPI: latest 0.13.0 (requires_python not set, summary "Websockify."). Dockerfile pins websockify v0.9.0 via git.
- License: noVNC LICENSE.txt is MPL 2.0. PyPI websockify license: LGPLv3.

## Gotchas
- Dockerfile base is linuxserver baseimage-alpine 3.14 with Alpine 3.9 community repo for py2-numpy; old pins.
- Dockerfile pins websockify 0.9.0 while PyPI latest is 0.13.0.
- Image ships no USER; chart runs root.
- Image uses /app as VOLUME; no non-root runtime user defined in the image itself.
