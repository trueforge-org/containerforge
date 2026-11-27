# ich777/docker-steamcmd-server branch chivalrymw (Dockerfile + scripts/start-server.sh)

## Source URL(s) + date
- https://api.github.com/repos/ich777/docker-steamcmd-server/contents/Dockerfile?ref=chivalrymw (fetched 2026-11-27)
- https://api.github.com/repos/ich777/docker-steamcmd-server/contents/scripts/start-server.sh?ref=chivalrymw (fetched 2026-11-27)

## Dockerfile (branch chivalrymw, 950 bytes; differs from master)
- `FROM ich777/debian-baseimage` (no tag in this file)
- LABEL source https://github.com/ich777/docker-steamcmd-server
- apt: `dpkg --add-architecture i386`; install `lib32gcc-s1 libstdc++6:i386`
- ENV: DATA_DIR=/serverdata, STEAMCMD_DIR=${DATA_DIR}/steamcmd, SERVER_DIR=${DATA_DIR}/serverfiles, GAME_ID=template, GAME_NAME=template, GAME_PARAMS=template, GAME_PORT=27015, VALIDATE="", UMASK=000, UID=99, GID=100, USERNAME="", PASSWRD="", USER=steam, DATA_PERM=770
- mkdir DATA_DIR, STEAMCMD_DIR, SERVER_DIR; `useradd -d $SERVER_DIR -s /bin/bash steam`; chown SERVER_DIR
- `ADD /scripts/ /opt/scripts/`; chmod 770
- `ENTRYPOINT ["/opt/scripts/start.sh"]`

## start-server.sh (branch chivalrymw, 2341 bytes)
- If `${STEAMCMD_DIR}/steamcmd.sh` missing: wget `http://media.steampowered.com/client/steamcmd_linux.tar.gz` and extract.
- SteamCMD update: anonymous login (if USERNAME empty) else `+login ${USERNAME} ${PASSWRD}`, `+quit`.
- Server update: `+force_install_dir ${SERVER_DIR} +login ... +app_update ${GAME_ID} [validate] +quit`.
- Post-install: copies `${STEAMCMD_DIR}/linux32/steamclient.so` to `${SERVER_DIR}/Binaries/Linux/lib/` if missing; writes `steam_appid.txt` = `219640` in `${SERVER_DIR}/Binaries/Linux/` if missing.
- sed on `${SERVER_DIR}/UDKGame/Config/PCServer-UDKGame.ini`: ServerName=Chivalry Docker; MessageOfTheDay text.
- `chmod -R ${DATA_PERM} ${DATA_DIR}`
- Start: `cd ${SERVER_DIR}/Binaries/Linux`; `${SERVER_DIR}/Binaries/Linux/UDKGameServer-Linux ${MAP}?adminpassword=${ADMIN_PWD}?steamsockets${GAME_PARAMS} ${GAME_PARAMS_EXTRA}`

## Runtime deps
- lib32gcc-s1, libstdc++6:i386, SteamCMD (downloaded at runtime).

## Entrypoint/flags
- ENTRYPOINT /opt/scripts/start.sh (Dockerfile). Launch binary `UDKGameServer-Linux`.

## Env vars used by script
- DATA_DIR, STEAMCMD_DIR, SERVER_DIR, GAME_ID, GAME_PARAMS, GAME_PARAMS_EXTRA, MAP, ADMIN_PWD, USERNAME, PASSWRD, VALIDATE, DATA_PERM

## Ports
- Not EXPOSEd. Game ports come from GAME_PARAMS (7000, 7010 per chart); GAME_PORT default 27015.

## User/UID
- ENV UID=99, GID=100 set but not referenced in this Dockerfile; user `steam` created with useradd (no USER line).

## Gotchas
- Last commit on branch 2022-10-25 (per plan.md; not re-verified here).
- steam_appid.txt 219640 differs from GAME_ID 220070 (store app ID per chart).
- Script writes into SERVER_DIR and STEAMCMD_DIR; no USER line in Dockerfile, so runs as root unless the base sets USER.
