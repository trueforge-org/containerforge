# deconz-community/deconz-docker Dockerfile

Source URL: https://raw.githubusercontent.com/deconz-community/deconz-docker/f23db7e09be257f35e3e753e69fda7494ea94d52/docker/Dockerfile (commit f23db7e, fetched 2026-11-27)

## What it is
Upstream image for deCONZ gateway (Zigbee), Debian 12 based, includes VNC/noVNC desktop tooling.

## Base
- `FROM debian:12-slim`
- Build args: VERSION, CHANNEL, TARGETPLATFORM, BUILDPLATFORM

## ENV (defaults)
| Name | Default |
| --- | --- |
| DEBIAN_FRONTEND | noninteractive |
| DECONZ_VERSION | ${VERSION} |
| DECONZ_WEB_PORT | 80 |
| DECONZ_WEBS_PORT | 0 |
| DECONZ_WS_PORT | 443 |
| DECONZ_DEVICE | 0 |
| DECONZ_VNC_MODE | 0 |
| DECONZ_VNC_DISPLAY | 0 |
| DECONZ_VNC_DISABLE_PASSWORD | 0 |
| DECONZ_VNC_PASSWORD | changeme |
| DECONZ_VNC_PASSWORD_FILE | 0 |
| DECONZ_VNC_PORT | 5900 |
| DECONZ_NOVNC_PORT | 6080 |
| DECONZ_UPNP | 1 |
| DECONZ_UID | 1000 |
| DECONZ_GID | 1000 |
| DECONZ_START_VERBOSE | 0 |
| DECONZ_BAUDRATE | 0 |
| DECONZ_APPDATA_DIR | /opt/deCONZ |
| NON_ROOT | 0 |
| DEBUG_INFO | 1 (also DEBUG_APS, DEBUG_ZCL, DEBUG_ZDP, DEBUG_DDF, DEBUG_DEV, DEBUG_OTA, DEBUG_ERROR, DEBUG_HTTP = 0; DECONZ_DEV_TEST_MANAGED = 0) |

## Install steps
- apt (single RUN): gosu, curl, kmod, udev, libatomic1, libcap2-bin, libqt5core5a, libqt5gui5, libqt5network5, libqt5serialport5, libqt5sql5, libqt5websockets5, libqt5widgets5, libqt5qml5, libssl3, libssl-dev, lsof, sqlite3, tigervnc-standalone-server, tigervnc-common, novnc, websockify, openbox, xfonts-base, xfonts-scalable; then apt clean and rm lists.
- amd64 only: install binutils, then `strip --remove-section=.note.ABI-tag /usr/lib/x86_64-linux-gnu/libQt5Core.so.5` (issue #292 workaround).
- `COPY root /` then `chmod +x /start.sh /firmware-update.sh`.
- User: `groupadd -g ${DECONZ_GID} deconz`; `useradd -u ${DECONZ_UID} -g deconz -G dialout -ms /bin/bash deconz`.
- `COPY download-deconz.sh /` and run `/download-deconz.sh ${VERSION} ${CHANNEL} ${TARGETPLATFORM}`.
- `dpkg -i /deconz.deb`; `chown root:root /usr/bin/deCONZ*`; `setcap CAP_NET_BIND_SERVICE=+eip /usr/bin/deCONZ`; `rm -f /deconz.deb`.

## Volumes
- VOLUME `/opt/deCONZ`

## Healthcheck
- `--interval=10s --timeout=20s --retries=5 CMD curl -I 127.0.0.1:${DECONZ_WEB_PORT} || exit 1`

## Ports
- EXPOSE ${DECONZ_WEB_PORT} ${DECONZ_WS_PORT} ${DECONZ_VNC_PORT} ${DECONZ_NOVNC_PORT} (80, 443, 5900, 6080 by default)

## Entrypoint
- `ENTRYPOINT ["/start.sh"]` (upstream root/ start.sh, not fetched)

## User/UID
- No USER directive. Built-in user `deconz` uid 1000 / gid 1000 by default (ARGs DECONZ_UID/DECONZ_GID).

## Gotchas
- Binary is installed as /usr/bin/deCONZ (setcap applied there).
- Qt5 packages are Debian bookworm-era names (libqt5*5a); verify on the target base.
