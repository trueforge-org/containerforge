# ich777/docker-thunderbird (Dockerfile)

Source URL(s) + date: https://raw.githubusercontent.com/ich777/docker-thunderbird/master/Dockerfile (also reachable via github blob URL; fetched 2026-11-27)

## What it is
- Upstream image source for `ghcr.io/ich777/thunderbird`: Thunderbird served via noVNC.

## Build
- `FROM ich777/novnc-baseimage` (base image ref, not fetched).
- apt install (no recommends): bzip2, libgtk-3-0, libdbus-glib-1-2, ttf-wqy-zenhei, fonts-wqy-microhei, fonts-takao, fonts-arphic-uming, fonts-noto-cjk, libasound2, xz-utils.
- Timezone set to Europe/Rome; `/var/lib/apt/lists` removed.
- Patches `/usr/share/novnc/app/ui.js` title to "Thunderbird - noVNC"; removes noVNC icons, then copies `/icons/*` and `/conf/` (`/etc/.fluxbox/`).
- `ADD /scripts/ /opt/scripts/`; `chmod -R 770 /opt/scripts/`.

## Runtime deps
- Thunderbird itself is not installed in the Dockerfile. Install logic lives in `/opt/scripts/` (start.sh not fetched); `THUNDERBIRD_V` is the version input.

## Entrypoint/flags
- `ENTRYPOINT ["/opt/scripts/start.sh"]`.
- `ulimit -n 2048` is set inside a RUN step (no effect on the runtime shell).

## Env vars
| Var | Default |
| --- | --- |
| DATA_DIR | /thunderbird |
| CUSTOM_RES_W | 1024 |
| CUSTOM_RES_H | 768 |
| CUSTOM_DEPTH | 16 |
| NOVNC_PORT | 8080 |
| RFB_PORT | 5900 |
| THUNDERBIRD_V | "latest" |
| THUNDERBIRD_LANG | "en-US" |
| TURBOVNC_PARAMS | "-securitytypes none" |
| UMASK | 000 |
| UID | 99 |
| GID | 100 |
| DATA_PERM | 770 |
| USER | thunderbird |

## Ports
- EXPOSE 8080 (noVNC).

## Volumes/paths
- `/thunderbird` (DATA_DIR), created and chowned to `thunderbird` user.

## User/UID
- `useradd -d /thunderbird -s /bin/bash thunderbird`; default UID/GID env 99/100 (script-driven).

## Gotchas
- Root-owned `/opt/scripts` path and chmod 770 only; no read-only-rootfs design.
- `LABEL org.opencontainers.image.source` points to ich777 repo, not trueforge.
