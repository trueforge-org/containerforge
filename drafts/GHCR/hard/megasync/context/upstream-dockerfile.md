# ich777/docker-megasync Dockerfile (upstream)

Source URL(s) + date: https://raw.githubusercontent.com/ich777/docker-megasync/master/Dockerfile · fetched 2026-11-27

## Build
- Base: `ich777/novnc-baseimage` (no tag); ARG DEBIAN_V="12"
- TZ Europe/Rome
- apt: large list of runtime libs (Qt5 core/gui/network/svg/widgets/x11extras, libcrypto++, libcurl3-gnutls, libmediainfo0v5, libzen0v5, libraw20, libtinyxml2-9, libicu72, libssl3, qml-module-qtquick-controls2, x11-xserver-utils, gpg, fontconfig, and others)
- MEGAsync install: scrapes https://mega.nz/linux/repo/Debian_${DEBIAN_V}/amd64/ for the megasync_*_amd64.deb name, downloads it to /tmp/MegaSync.deb, `apt-get install` it, removes the file
- noVNC title patched in /usr/share/novnc/app/ui.js; icons removed and replaced from /icons/
- COPY /conf/ -> /etc/.fluxbox/

## Env vars (ENV)
| Var | Default |
| --- | --- |
| DATA_DIR | /megasync |
| CUSTOM_RES_W | 750 |
| CUSTOM_RES_H | 550 |
| CUSTOM_DEPTH | 16 |
| NOVNC_PORT | 8080 |
| RFB_PORT | 5900 |
| TURBOVNC_PARAMS | "-securitytypes none" |
| UMASK | 000 |
| UID | 99 |
| GID | 100 |
| DATA_PERM | 770 |
| USER | megasync |

## User
- `useradd -d /megasync -s /bin/bash megasync`; chown -R on DATA_DIR

## Ports / entrypoint
- EXPOSE 8080 (noVNC)
- ENTRYPOINT ["/opt/scripts/start.sh"]

## Gotchas
- Version is scraped at build time from the MEGA repo (no pin); build depends on mega.nz being reachable.
- Repo path is Debian 12 amd64 only; arm64 deb path (xUbuntu/Debian arm64) appears in urls.txt but not in this Dockerfile.
- Chart CUSTOM_RES values (800x600) differ from image defaults (750x550).
