# Upstream scripts: ich777/docker-steamcmd-server, branch `unturned` (start.sh, start-server.sh)

Source URL(s) + date: https://raw.githubusercontent.com/ich777/docker-steamcmd-server/unturned/scripts/start.sh and .../scripts/start-server.sh (fetched 2026-11-27). Compared against master copies (cached summary ich777-docker-steamcmd-server.md).

## start.sh (diff vs master)
- Same as master except the CSDM fix block (chmod 550 on cssdm.games.txt) is removed.

## start-server.sh (branch-specific; differs substantially from master)
1. `LD_LIBRARY_PATH` += `${SERVER_DIR}/Unturned_Headless_Data/Plugins/x86_64/`.
2. If `${STEAMCMD_DIR}/steamcmd.sh` missing: wget `http://media.steampowered.com/client/steamcmd_linux.tar.gz` to STEAMCMD_DIR, tar extract (literal path /serverdata/steamcmd/...), rm tarball.
3. SteamCMD self-update: `+login anonymous +quit` or `+login ${USERNAME} ${PASSWRD} +quit`.
4. App update: `+force_install_dir ${SERVER_DIR} +login ... +app_update ${GAME_ID} [validate] +quit`; validate when VALIDATE == "true".
5. Rocket mod (only if ROCKET_MOD == "true"):
   - if `${SERVER_DIR}/Modules` file does NOT exist: wget ROCKET_URL (-nc), on failure `sleep infinity`; `unzip ${SERVER_DIR}/Rocket.zip`; rm Rocket.zip.
   - note: test is `-f` on a path named `Modules` (a directory in Rocket layout would fail this check; unverified).
   - if ROCKET_FORCE_UPDATE == "true": re-download and `unzip -o`.
6. Prep: `${DATA_DIR}/.steam/sdk64/steamclient.so` copied from `${STEAMCMD_DIR}/linux64/steamclient.so` if missing; `chmod -R ${DATA_PERM} ${DATA_DIR}`.
7. Start: `cd ${SERVER_DIR}; ${SERVER_DIR}/Unturned_Headless.x86_64 -nographics ${GAME_PARAMS} -port:${GAME_PORT} -sv` (no srcds_run; no exec).

## Gotchas
- Branch start-server.sh uses sdk64 (master uses sdk32).
- `sleep infinity` on download failure keeps the container alive without a server.
- Start is not `exec`, so PID 1 is bash (signal handling not forwarded).
