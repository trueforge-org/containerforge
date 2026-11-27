# ich777/docker-steamcmd-server branch citadelfwf (Dockerfile + scripts/start-server.sh)

## Source URL(s) + date
- https://api.github.com/repos/ich777/docker-steamcmd-server/branches (fetched 2026-11-27; branch `citadelfwf` head commit 73399a8ee)
- https://api.github.com/repos/ich777/docker-steamcmd-server/contents/Dockerfile?ref=citadelfwf (fetched 2026-11-27)
- https://api.github.com/repos/ich777/docker-steamcmd-server/contents/scripts/start-server.sh?ref=citadelfwf (fetched 2026-11-27)

## Dockerfile (branch citadelfwf, 895 bytes)
- `FROM ich777/debian-baseimage`
- LABEL source https://github.com/ich777/docker-steamcmd-server
- apt: `apt-get update`; install `lib32gcc-s1` only (no i386 libstdc++, unlike chivalrymw)
- ENV: DATA_DIR=/serverdata, STEAMCMD_DIR=${DATA_DIR}/steamcmd, SERVER_DIR=${DATA_DIR}/serverfiles, GAME_ID=template, GAME_NAME=template, GAME_PARAMS=template, GAME_PORT=27015, VALIDATE="", UMASK=000, UID=99, GID=100, USERNAME="", PASSWRD="", USER=steam, DATA_PERM=770
- mkdir DATA_DIR, STEAMCMD_DIR, SERVER_DIR; `useradd -d $DATA_DIR -s /bin/bash steam`; chown DATA_DIR
- `ADD /scripts/ /opt/scripts/`; chmod 770
- `ENTRYPOINT ["/opt/scripts/start.sh"]`

## start-server.sh (branch citadelfwf, 1762 bytes; this file is the one the chart runs)
- If `${STEAMCMD_DIR}/steamcmd.sh` missing: wget `http://media.steampowered.com/client/steamcmd_linux.tar.gz` and extract.
- SteamCMD update: anonymous (USERNAME empty) or `+login ${USERNAME} ${PASSWRD}`, `+quit`.
- Server update: `+force_install_dir ${SERVER_DIR} +login ... +app_update ${GAME_ID} [validate] +quit`.
- `export LD_LIBRARY_PATH="${SERVER_DIR}/linux64/:$LD_LIBRARY_PATH"`; `chmod -R ${DATA_PERM} ${DATA_DIR}`.
- Start: `cd ${SERVER_DIR}`; `${SERVER_DIR}/Citadel/Binaries/Linux/CitadelServer-Linux-Shipping ${GAME_PARAMS}`

## Runtime deps
- lib32gcc-s1; SteamCMD (downloaded at runtime).

## Entrypoint/flags
- ENTRYPOINT /opt/scripts/start.sh (Dockerfile). Server binary `CitadelServer-Linux-Shipping`, args = GAME_PARAMS only.

## Env vars used by script
- DATA_DIR, STEAMCMD_DIR, SERVER_DIR, GAME_ID, GAME_PARAMS, USERNAME, PASSWRD, VALIDATE, DATA_PERM

## Ports
- Not EXPOSEd. Chart uses 7777 udp and 27015 udp; GAME_PARAMS is empty in the chart.

## Gotchas
- Branch last commit 2022-10-25 (per plan.md; not re-verified).
- Script does not write steam_appid.txt (unlike chivalrymw branch).
- Dockerfile here differs from chivalrymw branch (no i386 libstdc++ install; useradd home is DATA_DIR instead of SERVER_DIR).
