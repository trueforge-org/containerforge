# ich777/docker-xonotic-server (Dockerfile, scripts/start.sh, scripts/start-server.sh)

Source URL(s): https://raw.githubusercontent.com/ich777/docker-xonotic-server/master/Dockerfile ; .../master/scripts/start.sh ; .../master/scripts/start-server.sh (fetched 2026-11-27, branch master, no pinned commit). The github tree/blob URLs are duplicates.

## Build
- `FROM ich777/debian-baseimage`; apt: curl, unzip (--no-install-recommends).
- ENV DATA_DIR=/serverdata, SERVER_DIR=${DATA_DIR}/serverfiles, BASIC_URL=https://dl.xonotic.org/, GAME_VERSION=0.8.5, GAME_PARAMS=template, GAME_PORT=26000, UMASK=000, UID=99, GID=100, DATA_PERM=770, USER=xonotic.
- mkdir DATA_DIR and SERVER_DIR; useradd -d DATA_DIR xonotic; chown; ADD scripts -> /opt/scripts (chmod 770).

## Entrypoint
- `ENTRYPOINT ["/opt/scripts/start.sh"]`; no CMD.

## start.sh (root)
- usermod/groupmod to UID/GID; umask ; optional /opt/custom/user.sh or /opt/scripts/user.sh.
- chown root:GID /opt/scripts (750); chown UID:GID DATA_DIR.
- SIGTERM trap sends "exit" to a screen session named nwnee (copy-paste from another game image; no screen session is created by start-server.sh) then waits.
- Runs start-server.sh as USER via su.

## start-server.sh (USER)
- Version marker: `serverfiles/xonoticinstalledv<ver>`. If no marker: downloads ${BASIC_URL}xonotic-${GAME_VERSION}.zip with wget -nc, unzips, moves Xonotic/* into SERVER_DIR, removes zip, touches marker.
- If marker version differs: removes old marker, downloads new zip, keeps data/server.cfg, reinstalls.
- If equal: "up-to-date".
- chmod -R DATA_PERM DATA_DIR; if data/server.cfg missing copies server/server.cfg; sed sets hostname "Xonotic Docker".
- Launch: `${SERVER_DIR}/xonotic-linux64-dedicated ${GAME_PARAMS}` (cwd SERVER_DIR). GAME_PORT is not passed to the binary here.

## Env vars
| Var | Default | Note |
| --- | --- | --- |
| GAME_VERSION | 0.8.5 | chart sets 0.8.2 |
| GAME_PARAMS | template | chart sets "" |
| GAME_PORT | 26000 | not used by start-server.sh |
| BASIC_URL | https://dl.xonotic.org/ | |
| UMASK | 000 | |
| UID / GID | 99 / 100 | |
| DATA_PERM | 770 | |
| DATA_DIR / SERVER_DIR | /serverdata / /serverdata/serverfiles | |
| USER | xonotic | |

## Ports
- 26000/udp.

## Volumes/paths
- /serverdata, /serverdata/serverfiles (chart mount), /serverdata/serverfiles/data/server.cfg.

## User/UID
- Root for setup, then xonotic (UID 99 / GID 100 default).

## Healthcheck
- None.

## Gotchas
- Entrypoint needs root (usermod/groupmod/chown/su): not read-only-rootfs compatible as-is.
- Download is at runtime (zip ~1182 MiB per plan); "sleep infinity" on failure.
- Version marker is file-based; changing GAME_VERSION triggers reinstall that keeps server.cfg.
