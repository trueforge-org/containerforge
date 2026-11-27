# ich777/docker-electrum Dockerfile

Source URL: https://raw.githubusercontent.com/ich777/docker-electrum/master/Dockerfile (fetched 2026-11-27, branch master, not pinned)

## What it is
Upstream image `ghcr.io/ich777/electrum`: Electrum Bitcoin wallet GUI, served through noVNC.

## Base
- `FROM ich777/novnc-baseimage` (no tag in Dockerfile; not fetched)
- LABELs: authors admin@minenet.at, source https://github.com/ich777/docker-electrum

## Build steps
- RUN: TZ=Europe/Rome; apt-get update; symlink /etc/localtime; `apt-get -y install --no-install-recommends python3-pyqt5 libsecp256k1-2 python3-cryptography python3-pyqt6`; rm apt lists
- sed on `/usr/share/novnc/app/ui.js`: document.title -> "Electrum - noVNC"; rm `/usr/share/novnc/app/images/icons/*`
- RUN: `mkdir $DATA_DIR`; `useradd -d $DATA_DIR -s /bin/bash $USER`; chown; `mkdir /etc/.fluxbox`; `ulimit -n 2048` (no persistent effect)
- `ADD /scripts/ /opt/scripts/`; `COPY /icons/*` to noVNC icons dir; `COPY /conf/ /etc/.fluxbox/`
- `chmod -R 770 /opt/scripts/`; `chown -R ${UID}:${GID} /etc/.fluxbox`; `chmod -R 770 /etc/.fluxbox`
- Electrum itself is NOT downloaded or pip-installed in this Dockerfile; it comes from the Debian/Ubuntu apt packages only (scripts may do more; not fetched).

## ENV
| Name | Default |
| --- | --- |
| DATA_DIR | /electrum |
| CUSTOM_RES_W | 1024 |
| CUSTOM_RES_H | 768 |
| CUSTOM_DEPTH | 16 |
| NOVNC_PORT | 8080 |
| RFB_PORT | 5900 |
| TURBOVNC_PARAMS | `-securitytypes none` |
| UMASK | 000 |
| UID | 99 |
| GID | 100 |
| DATA_PERM | 770 |
| USER | electrum |

## Ports
- EXPOSE 8080 (noVNC). RFB 5900 is an env default, not exposed.

## Volumes
- none declared; DATA_DIR `/electrum` is created in the image

## User/UID
- `useradd -d /electrum -s /bin/bash electrum` (no UID flag; UID/GID env vars are not used by useradd here). No USER directive; runtime user decided by start.sh (not fetched).

## Entrypoint
- `ENTRYPOINT ["/opt/scripts/start.sh"]`

## Gotchas
- Electrum version is not set here; it is whatever the apt packages provide.
- Qt5 and Qt6 PyQt both installed.
