# ich777/docker-steamcmd-server

## Source URL(s) + fetch date
- https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/README.md
- https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/Dockerfile
- https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/scripts/start.sh
- https://raw.githubusercontent.com/ich777/docker-steamcmd-server/master/scripts/start-server.sh
- Fetched 2026-11-26 (master branch only; per-game branches were not fetched)

## What it is
Generic SteamCMD-based dedicated-server image. The game is chosen at run time by `GAME_ID` (Steam app ID) and `GAME_NAME` (srcds game), not by the image itself. Upstream README says to check the available tags/branches for supported games. Built for Unraid, a fork of mattieserver's work.

## Install/build steps and build deps
- Base: `FROM ich777/debian-baseimage:bullseye_amd64` (Debian bullseye).
- `apt-get install --no-install-recommends lib32gcc-s1 lib32stdc++6 lib32z1`, then `rm -rf /var/lib/apt/lists/*`.
- Creates dirs `/serverdata`, `/serverdata/steamcmd`, `/serverdata/serverfiles`.
- `useradd -d /serverdata -s /bin/bash steam`; `chown -R steam /serverdata`.
- `RUN ulimit -n 2048` (no effect on runtime; a RUN shell does not persist limits).
- `ADD /scripts/ /opt/scripts/`; `chmod -R 770 /opt/scripts/`.
- No ARG, CMD, EXPOSE, VOLUME, HEALTHCHECK, or LABEL beyond `org.opencontainers.image.authors` and `org.opencontainers.image.source`.
- SteamCMD itself is NOT in the Dockerfile; `scripts/start-server.sh` downloads it at first start.

## Runtime deps
- 32-bit libs above (lib32gcc-s1, lib32stdc++6, lib32z1).
- Network access to media.steampowered.com (SteamCMD tarball) and Steam content servers at start.

## Entrypoint/CLI flags
- `ENTRYPOINT ["/opt/scripts/start.sh"]`, no CMD.
- `start.sh` runs as root, then runs `start-server.sh` as user `${USER}` via `su ${USER} -c`. Background process, with SIGTERM trap forwarding.
- `start-server.sh` flow:
  1. If `${STEAMCMD_DIR}/steamcmd.sh` missing: `wget -q -O ${STEAMCMD_DIR}/steamcmd_linux.tar.gz http://media.steampowered.com/client/steamcmd_linux.tar.gz`, then `tar --directory ${STEAMCMD_DIR} -xvzf /serverdata/steamcmd/steamcmd_linux.tar.gz`, then delete the tarball.
  2. SteamCMD self-update: `steamcmd.sh +login anonymous +quit` (or `+login ${USERNAME} ${PASSWRD} +quit` if USERNAME set).
  3. Game install/update: `steamcmd.sh +force_install_dir ${SERVER_DIR} +login anonymous +app_update ${GAME_ID} [validate] +quit`. Adds `validate` when `VALIDATE == "true"` (string compare). Uses USERNAME/PASSWRD login when USERNAME is non-empty.
  4. Prep: if `${DATA_DIR}/.steam/sdk32/steamclient.so` missing, creates `${DATA_DIR}/.steam/sdk32` and copies `${STEAMCMD_DIR}/linux32/*` into it. Then `chmod -R ${DATA_PERM} ${DATA_DIR}`.
  5. Start: `cd ${SERVER_DIR}; ${SERVER_DIR}/srcds_run -game ${GAME_NAME} ${GAME_PARAMS} -console +port ${GAME_PORT}`. `srcds_run` is Source-engine specific; the script assumes it exists in `${SERVER_DIR}`.
- `start.sh` before starting: `usermod -u ${UID} steam`; `groupmod -g ${GID}` (ignored if fails), `usermod -g ${GID} steam`; `umask ${UMASK}`; runs optional `/opt/custom/user.sh` or `/opt/scripts/user.sh` (copied to `/opt/scripts/start-user.sh`) if present; `chown -R root:${GID} /opt/scripts`; `chmod -R 750 /opt/scripts`; `chown -R ${UID}:${GID} ${DATA_DIR}`; CS:S CSDM fix chmod 550 on `cssdm.games.txt` if present.

## Env vars (table)
Dockerfile defaults (from `ENV`), and meaning from the README/scripts.

| Name | Dockerfile default | Meaning / used by |
| --- | --- | --- |
| DATA_DIR | `/serverdata` | Root data dir; chown'd to UID:GID |
| STEAMCMD_DIR | `${DATA_DIR}/steamcmd` | SteamCMD install dir |
| SERVER_DIR | `${DATA_DIR}/serverfiles` | Game files dir (`force_install_dir`) |
| GAME_ID | `template` | Steam app ID for `+app_update`. Append `-beta <branch>` (no quotes) for a beta branch (per README) |
| GAME_NAME | `template` | srcds `-game` value |
| GAME_PARAMS | `template` | Extra server startup args |
| GAME_PORT | `27015` | Passed as `+port` |
| VALIDATE | `""` | Set to `true` to run `app_update ... validate` |
| UMASK | `000` | umask applied in start.sh |
| UID | `99` | Runtime uid of user `steam` (usermod) |
| GID | `100` | Runtime gid of user `steam` (groupmod/usermod) |
| USERNAME | `""` | Empty = anonymous login |
| PASSWRD | `""` | Steam password (used only if USERNAME set) |
| USER | `steam` | Runtime user name |
| DATA_PERM | `770` | chmod mode applied recursively to DATA_DIR |

Note: `GAME_ID`, `GAME_NAME`, `GAME_PARAMS` default to the literal `template`; they must be set for a real game.

## Ports
- README example maps `27015/tcp` and `27015/udp` (CS:Source). Actual port is `GAME_PORT` (default 27015). The image itself has no EXPOSE.

## Volumes/paths
- README example: `/path/to/steamcmd` → `/serverdata/steamcmd`, `/path/to/cstrikesource` → `/serverdata/serverfiles`.
- No VOLUME instruction in Dockerfile.
- Scripts at `/opt/scripts` (chmod 750, root:GID). Optional user hook at `/opt/custom/user.sh`.
- `DATA_DIR/.steam/sdk32` holds the 32-bit steamclient libs.

## User/UID & permissions
- Image creates user `steam` (home `/serverdata`, shell `/bin/bash`) at build time with default uid/gid.
- Runtime: start.sh runs as root, remaps `steam` to `UID`/`GID`, then drops to `steam` via `su`. Defaults UID 99 / GID 100 (Unraid "nobody"/"users" convention).
- Container is NOT rootless in the sense used by the repo's rules: root is needed for usermod/groupmod/chown at start.

## Config files
- None shipped by this repo. Per-game configs live under `SERVER_DIR`. CSDM gamedata file is specifically handled.

## Healthcheck
- None defined.

## Version/asset naming
- No version pinning. Game version = whatever Steam serves for `GAME_ID` (optionally beta branch).
- Image tag selects the game (per README: check tags/branches).
- Docker example uses `ich777/steamcmd:latest`.

## Arch support
- Not stated in fetched files. Uses `linux32` SteamCMD libs and 32-bit Debian packages; base image tag `bullseye_amd64` indicates amd64.

## Gotchas
- SteamCMD tarball is fetched at runtime from `http://media.steampowered.com`, not baked in. Hard-coded path `/serverdata/steamcmd/steamcmd_linux.tar.gz` in `tar` and `wget` uses STEAMCMD_DIR only partially (the tar uses the literal path, not the variable).
- Password passed on the command line (`+login user pass`), so it is visible in process listings.
- `ulimit -n 2048` in a RUN line does not apply at container runtime.
- `start.sh` modifies `/etc/passwd`/`/etc/group` (usermod/groupmod) at every start, so a read-only rootfs or a non-root `USER` will break it.
- `srcds_run` is hard-wired; non-Source games will need a different start command.
- `GAME_ID` may be a beta spec like `232330 -beta branchname` per README.
- `GAME_PARAMS` is word-split unquoted into the command.
- Value compare for VALIDATE is the literal string `true`.
