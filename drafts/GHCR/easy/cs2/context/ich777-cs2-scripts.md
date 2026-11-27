# ich777/docker-steamcmd-server, branch cs2, scripts

## Source URL(s) + date
- https://raw.githubusercontent.com/ich777/docker-steamcmd-server/cs2/scripts/start.sh (fetched 2026-11-27)
- https://raw.githubusercontent.com/ich777/docker-steamcmd-server/cs2/scripts/start-server.sh (fetched 2026-11-27)

## start.sh (root wrapper)
- `usermod -u ${UID} steam`; `groupmod -g ${GID} steam` (errors ignored); `usermod -g ${GID} steam`
- `umask ${UMASK}`; runs `/opt/custom/user.sh` or `/opt/scripts/user.sh` if present (copied to `/opt/scripts/start-user.sh`)
- `chown -R root:${GID} /opt/scripts`; `chmod -R 750 /opt/scripts`; `chown -R ${UID}:${GID} ${DATA_DIR}`
- `su steam -c "/opt/scripts/start-server.sh" &`, SIGTERM trap, `wait` loop

## start-server.sh (as user steam)
1. If `${STEAMCMD_DIR}/steamcmd.sh` missing: `wget` `http://media.steampowered.com/client/steamcmd_linux.tar.gz` to `${STEAMCMD_DIR}`, `tar --directory ${STEAMCMD_DIR} -xvzf /serverdata/steamcmd/steamcmd_linux.tar.gz` (literal path), `rm` tarball.
2. SteamCMD self-update: `steamcmd.sh +login anonymous +quit` (or `+login ${USERNAME} ${PASSWRD} +quit` if USERNAME set).
3. Install/update: `steamcmd.sh +force_install_dir ${SERVER_DIR} +login anonymous +app_update ${GAME_ID} [validate] +quit`. `validate` added when `VALIDATE == "true"`. Login with USERNAME/PASSWRD when set.
4. Prep: if `${DATA_DIR}/.steam/sdk64/steamclient.so` missing, creates `${DATA_DIR}/.steam/sdk64` and copies `${STEAMCMD_DIR}/linux64/*` into it. Then `chmod -R ${DATA_PERM} ${DATA_DIR}`.
5. Start: `cd ${SERVER_DIR}`; `export LD_LIBRARY_PATH="${SERVER_DIR}"/bin/linuxsteamrt64:$LD_LIBRARY_PATH`; `export USE_STEAM_RUNTIME=1`; `${SERVER_DIR}/game/bin/linuxsteamrt64/cs2 ${GAME_PARAMS}`.

## Runtime notes
- Uses `linux64` SteamCMD libs (sdk64), not `linux32` as on master (srcds_run path).
- GAME_PORT is not passed to cs2; ports only via GAME_PARAMS (for example `-port`).

## Gotchas
- Password is passed on the command line (`+login user pass`), visible in process listings.
- `GAME_PARAMS` is word-split unquoted.
- VALIDATE compare is the literal string `true`.
- The `tar` line hard-codes `/serverdata/steamcmd/...`.
