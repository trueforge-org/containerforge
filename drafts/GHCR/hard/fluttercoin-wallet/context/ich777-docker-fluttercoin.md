# ich777/docker-fluttercoin (build source of ghcr.io/ich777/fluttercoin)

Source URL(s): https://raw.githubusercontent.com/ich777/docker-fluttercoin/master/Dockerfile , .../master/scripts/start.sh (fetched 2026-11-27; blob/ variant of Dockerfile is the same file)

## Build (Dockerfile)
- FROM ich777/novnc-baseimage:buster_amd64 (Debian buster, amd64 only).
- Labels: org.opencontainers.image.source=https://github.com/ich777/docker-fluttercoin, authors admin@minenet.at.
- apt install --no-install-recommends: libqtgui4, unzip. TZ set to Europe/Rome.
- sed patches /usr/share/novnc/app/ui.js document.title to "Fluttercoin - noVNC"; removes noVNC icons, copies /icons/* into noVNC icons dir.
- Copies /scripts/ -> /opt/scripts/, /conf/ -> /etc/.fluxbox/; chmod -R 770 /opt/scripts/.
- Creates DATA_DIR /fluttercoin, user `fluttercoin` (useradd -d /fluttercoin -s /bin/bash), chown data dir.
- ENTRYPOINT ["/opt/scripts/start.sh"]. EXPOSE 8080 7408 7474.

## Runtime deps
- noVNC/X base image (from baseimage), libqtgui4 (Qt4 GUI runtime for fluttercoin-qt), unzip.

## Entrypoint (start.sh)
- Remaps user `${USER}` uid to `${UID}`, group to `${GID}`; umask `${UMASK}`.
- Optional user script: /opt/custom/user.sh or /opt/scripts/user.sh copied to start-user.sh and run.
- Runs `novnccheck`; chown root:${GID} /opt/scripts, chmod 750; chown ${UID}:${GID} ${DATA_DIR}.
- Runs `su ${USER} -c "/opt/scripts/start-server.sh"` in background; SIGTERM trap kills `fluttercoin-qt` then exits 143.

## Env vars (Dockerfile defaults)
| Name | Default |
| --- | --- |
| DATA_DIR | /fluttercoin |
| CUSTOM_RES_W | 1024 |
| CUSTOM_RES_H | 768 |
| NOVNC_PORT | 8080 |
| RFB_PORT | 5900 |
| X11VNC_PARAMS | "" |
| UMASK | 000 |
| UID | 99 |
| GID | 100 |
| DATA_PERM | 770 |
| USER | fluttercoin |

## Ports
- 8080 (noVNC), 7408 (P2P), 7474 (JSON RPC). 5900 RFB is an env default only, not EXPOSEd.

## Volumes/paths
- /fluttercoin (data dir), /opt/scripts, /usr/share/novnc/app/images/icons.

## User/UID
- Container starts as root for setup; service runs as `fluttercoin` (UID/GID remapped from env, default 99/100).

## Healthcheck
- None in Dockerfile.

## Gotchas
- Dockerfile not read-only-rootfs friendly: start.sh chowns and usermod/groupmod at runtime, requires root.
- Build is amd64-only (buster base tag).
- start-server.sh (launch of fluttercoin-qt) not fetched.
