# tsightler/ring-mqtt Dockerfile (commit 59aab41)

Source: https://github.com/tsightler/ring-mqtt/blob/59aab41/Dockerfile (raw, pinned commit), fetched 2026-11-26. Full file read.

## Build
- Base: `FROM node:jod-alpine` (Node 22 Alpine tag family; exact version not stated in file).
- `COPY . /app/ring-mqtt`.
- apk add: tar xz git bash curl jq tzdata mosquitto-clients.
- Pinned by ARG-less variables in RUN:
  - `S6_VERSION="v3.2.2.0"` (just-containers/s6-overlay: noarch + `${APK_ARCH}` tarballs; armv7 uses `s6-overlay-arm.tar.xz`)
  - `BASHIO_VERSION="v0.17.5"` (hassio-addons/bashio, tarball `lib` -> /usr/lib/bashio, symlink /usr/bin/bashio)
  - `GO2RTC_VERSION="v1.9.14"` (AlexxIT/go2rtc, binary `go2rtc_linux_${GO2RTC_ARCH}` -> /usr/local/bin/go2rtc)
- Arch map (`apk --print-arch`): x86_64 -> amd64 (go2rtc); aarch64 -> arm64; armv7|armhf -> arm; other arch -> error exit. s6 tarballs for aarch64, armhf, x86_64, armv7.
- s6 init: `cp -a /app/ring-mqtt/init/s6/* /etc/.`; chmod cont-init.d/*.sh and services.d/ring-mqtt/*; removes /app/ring-mqtt/init.
- `mkdir /data`; `chmod 777 /data /app /run`.
- `chmod +x` on scripts/*.sh, ring-mqtt.js, init-ring-mqtt.js.
- `cd /app/ring-mqtt && npm install`; cleanup /root/.npm, /tmp/*.

## Runtime
- `ENTRYPOINT ["/init"]` (s6-overlay). No USER directive: runs as root.
- `EXPOSE 8554/tcp` (RTSP gateway), `EXPOSE 55123/tcp` (web/API).
- No VOLUME directive; /data created but not declared.
- Labels: io.hass.* (HA add-on), `org.opencontainers.image.licenses="MIT"`, source https://github.com/tsightler/ring-mqtt. Build args: BUILD_VERSION, BUILD_DATE.

## Env (ENV)
| Var | Value |
| --- | --- |
| LANG | C.UTF-8 |
| TERM | xterm-256color |
| PS1 | prompt string |
| S6_BEHAVIOUR_IF_STAGE2_FAILS | 2 |
| S6_CMD_WAIT_FOR_SERVICES | 1 |
| S6_CMD_WAIT_FOR_SERVICES_MAXTIME | 0 |
| S6_SERVICES_GRACETIME | 10000 |

## Gotchas
- Runs as root; `/app`, `/run`, `/data` chmod 777.
- Downloads s6, bashio, go2rtc from GitHub at build time with version pins in RUN (not ARG); checksums not verified (no sha check in file).
- Uses `curl -L -s` without failure checks on the s6 pipe.
- `npm install` (no lockfile step visible).
