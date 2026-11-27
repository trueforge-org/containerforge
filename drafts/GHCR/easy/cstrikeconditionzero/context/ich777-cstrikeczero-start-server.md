# ich777/docker-steamcmd-server, branch cstrikeczero, scripts/start-server.sh

## Source URL(s) + date
- https://raw.githubusercontent.com/ich777/docker-steamcmd-server/cstrikeczero/scripts/start-server.sh (fetched 2026-11-27)
- Parent flow (start.sh, Dockerfile): see ich777-docker-steamcmd-server.md (master branch).

## Steps (as user steam)
1. If `${STEAMCMD_DIR}/steamcmd.sh` missing: wget `http://media.steampowered.com/client/steamcmd_linux.tar.gz`, `tar --directory ${STEAMCMD_DIR} -xvzf /serverdata/steamcmd/steamcmd_linux.tar.gz`, rm tarball.
2. SteamCMD self-update: `+login anonymous +quit` (or `+login ${USERNAME} ${PASSWRD} +quit`).
3. Install: `steamcmd.sh +force_install_dir ${SERVER_DIR} +login <anon|USERNAME PASSWRD> +app_set_config ${GAME_MOD} +app_update ${GAME_ID} [validate] +quit`. `validate` when `VALIDATE == "true"`.
4. Check: if `${SERVER_DIR}/czero` dir missing, runs the same install again with `validate`.
5. Prep: `mkdir ${DATA_DIR}/.steam/sdk32` (no -p); `cp ${SERVER_DIR}/steamclient.so ${DATA_DIR}/.steam/sdk32/steamclient.so`; `chmod -R ${DATA_PERM} ${DATA_DIR}`.
6. Start: `cd ${SERVER_DIR}`; `${SERVER_DIR}/hlds_run -game ${GAME_NAME} ${GAME_PARAMS} -console +port ${GAME_PORT}`.

## Differences from master
- Master uses `srcds_run` and `linux32/*` SDK copy. This branch uses `hlds_run` and copies `steamclient.so` from `${SERVER_DIR}`.
- Install step runs `+app_set_config ${GAME_MOD}` before `+app_update`.

## Gotchas
- `mkdir` without `-p` fails if `.steam` is missing.
- `${GAME_ID}` and `${GAME_MOD}` are expanded unquoted, so the chart's `GAME_ID` value (with extra args) would be split into several steamcmd arguments.
- Password is on the command line (`+login user pass`).
