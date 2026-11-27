# ich777/docker-rapidphotodownloader Dockerfile

**Source URL(s):** https://raw.githubusercontent.com/ich777/docker-rapidphotodownloader/master/Dockerfile (blob URL is a duplicate) · fetched 2026-11-27

## Build
- `FROM ich777/novnc-baseimage:bullseye_amd64` (Debian bullseye).
- One big apt install (dozens of python3, gtk, gstreamer, exiv2, libgphoto2, libraw, python3-gi, python3-tk, zenity, libqt5x11extras5, ifuse, libimobiledevice-utils, etc.), timezone Europe/Rome, `ko_KR` and `ja_JP` locales.
- Patches `/usr/share/novnc/app/ui.js` document title; removes noVNC icons, copies custom icons and `/conf/` to `/etc/.fluxbox/`.
- Lines in build commented out: libxcb-util1 deb install.

## Runtime
- `ENTRYPOINT ["/opt/scripts/start.sh"]`.
- `EXPOSE 8080`.
- `ADD /scripts/ /opt/scripts/`; `chmod -R 770 /opt/scripts/`.
- `useradd -d $DATA_DIR -s /bin/bash $USER`; `chown -R $USER $DATA_DIR`; sudoers `rpd ALL=(root) NOPASSWD:/usr/bin/apt-get`.

## Env (Dockerfile ENV)
| var | value |
| --- | --- |
| DATA_DIR | /rapidphotodownloader |
| DL_URL | https://launchpad.net/rapid/pyqt/0.9.17/+download/install.py |
| FORCE_UPDATE | "" |
| CUSTOM_RES_W | 1024 |
| CUSTOM_RES_H | 881 |
| CUSTOM_DEPTH | 16 |
| NOVNC_PORT | 8080 |
| RFB_PORT | 5900 |
| TURBOVNC_PARAMS | -securitytypes none |
| UMASK | 000 |
| UID | 99 |
| GID | 100 |
| DATA_PERM | 770 |
| USER | rpd |

## User/UID
- Runtime user `rpd` (uid/gid remapped at start from UID/GID).

## Gotchas
- Container root is needed at start (usermod/groupmod/chown).
- Locale and icon edits happen at build time.
