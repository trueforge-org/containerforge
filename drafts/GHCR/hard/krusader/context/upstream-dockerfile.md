# ich777/docker-krusader Dockerfile (upstream)

Source URL(s) + date: https://raw.githubusercontent.com/ich777/docker-krusader/master/Dockerfile · fetched 2026-11-27

## Build
- Base: `ich777/novnc-baseimage:bookworm_amd64`
- apt source: Debian bookworm (contrib non-free non-free-firmware), TZ Europe/Rome
- Packages: krusader, breeze-icon-theme, kompare, krename, bzip2, lzma, xz-utils, lhasa, zip, unzip, arj, unace, rar, unrar, p7zip-full, rpm, konsole, gedit, dbus-x11, keditbookmarks, feh, fonts-takao, fonts-arphic-uming, fonts-noto-cjk
- Locales: ko_KR.UTF-8, ja_JP.UTF-8 added and generated
- noVNC title patched in /usr/share/novnc/app/ui.js; icons replaced from /icons/
- COPY locales_krusader.tar -> extracted to /

## Env vars (ENV)
| Var | Default |
| --- | --- |
| DATA_DIR | /krusader |
| CUSTOM_RES_W | 1280 |
| CUSTOM_RES_H | 768 |
| CUSTOM_DEPTH | 16 |
| NOVNC_PORT | 8080 |
| RFB_PORT | 5900 |
| TURBOVNC_PARAMS | "-securitytypes none" |
| UMASK | 000 |
| UID | 99 |
| GID | 100 |
| DATA_PERM | 770 |
| USER | krusader |
| USER_LOCALES | en_US.UTF-8 UTF-8 |

## User
- `useradd -d /krusader -s /bin/bash krusader`; chown -R on DATA_DIR
- /mnt chowned to ${UID}:${GID} and chmod 770

## Ports
- EXPOSE 8080 (noVNC). RFB 5900 set via ENV, not exposed.

## Entrypoint
- `ENTRYPOINT ["/opt/scripts/start.sh"]`
- Fluxbox config copied to /etc/.fluxbox/

## Gotchas
- Dockerfile sets `ulimit -n 2048` in a RUN step (no runtime effect).
- Starts a VNC/noVNC desktop; needs /tmp and writable paths for Xvnc/fluxbox.
