# ich777/docker-urbanterror (Dockerfile, scripts/start.sh, scripts/start-server.sh, README)

Source URL(s): https://raw.githubusercontent.com/ich777/docker-urbanterror/master/Dockerfile ; .../master/README.md ; .../master/scripts/start.sh ; .../master/scripts/start-server.sh (fetched 2026-11-27, branch master, no pinned commit)

## What it is
- Urban Terror (Quake III engine, UrT 4.3) dedicated server, installed at first start from the official installer.

## Build
- `FROM ich777/debian-baseimage`.
- apt: curl, libxml2-utils, libsdl2-2.0-0 (--no-install-recommends).
- ENV DATA_DIR=/urbanterror, CONFIG_NAME=server.cfg, DL_URL=http://www.urbanterror.info/downloads/software/urt/43/UrbanTerror43_ded.tar.gz, GAME_V=1, DL_LOCATION=1, ENGINE=1, CHECK_FOR_UPDATES=true, GAME_PORT=27960, START_PARAMS="", UMASK=0000, DATA_PERM=770, UID=99, GID=100, USER=urbanterror.
- `mkdir $DATA_DIR`, `useradd -d $DATA_DIR -s /bin/bash $USER`, chown datadir; `ulimit -n 2048` (no effect in RUN).
- ADD /scripts/ -> /opt/scripts/, chmod 770.

## Entrypoint
- `ENTRYPOINT ["/opt/scripts/start.sh"]`, no CMD.

## start.sh (runs as root)
- `usermod -u ${UID}`, `groupmod -g ${GID}`, `usermod -g ${GID}`; `umask ${UMASK}`.
- Optional user script: /opt/custom/user.sh or /opt/scripts/user.sh copied to start-user.sh and run.
- chown -R root:${GID} /opt/scripts; chmod 750; chown -R ${UID}:${GID} ${DATA_DIR}.
- Traps SIGTERM; runs `su ${USER} -c /opt/scripts/start-server.sh` in background, waits.

## start-server.sh (runs as USER)
- If no `${DATA_DIR}/Ur*.sh` updater: fetches the tar.gz link scraped from DL_URL via wget, extracts to DATA_DIR (strip 1), chmod +x.
- If no `${DATA_DIR}/Quake3-UrT-Ded.x86_64`: runs the updater with piped answers (y, GAME_V, DL_LOCATION, ENGINE, n).
- Else if CHECK_FOR_UPDATES == true: runs updater again.
- Config: if `${DATA_DIR}/q3ut4/${CONFIG_NAME}` missing and CONFIG_NAME == server.cfg: copies q3ut4/server_example.cfg and sets sv_hostname "Docker Server". If CONFIG_NAME is custom and missing: `sleep infinity`.
- `chmod -R ${DATA_PERM} ${DATA_DIR}`.
- Launch: `${DATA_DIR}/Quake3-UrT-Ded.x86_64 +set net_port ${GAME_PORT} +set fs_homepath ${DATA_DIR} +exec server.cfg ${START_PARAMS}`.

## Env vars (README table)
| Name | Value | Note |
| --- | --- | --- |
| DATA_DIR | /urbanterror | app + config |
| CONFIG_NAME | server.cfg | only used for config existence check; launch hardcodes `+exec server.cfg` |
| START_PARAMS | "" | extra params |
| CHECK_FOR_UPDATES | true | update check on each start |
| UID / GID | 99 / 100 | |
| UMASK | 0000 | |
| DATA_PERMS | 770 | README says DATA_PERMS, script uses DATA_PERM |

## Ports
- 27960/udp (GAME_PORT).

## Volumes/paths
- /urbanterror (DATA_DIR): q3ut4/ config dir, Quake3-UrT-Ded.x86_64 binary, Ur*.sh updater.

## User/UID
- Container starts as root for usermod/chown, then drops to `urbanterror` via su. Default UID 99 / GID 100.

## Healthcheck
- None.

## Arch
- Not stated (x86_64 binary `Quake3-UrT-Ded.x86_64`): x86_64 only.

## Gotchas
- First start can take up to 30 min (README) due to download.
- Needs root in entrypoint (usermod/groupmod/chown/su): not rootless or read-only-rootfs compatible as-is.
- Download source is a binary from urbanterror.info (not fetched; binary download category).
- Dockerfile sets `ulimit -n 2048` in RUN; it does not persist.
- Update check runs `echo "y\n"` (literal, non-portable echo).
