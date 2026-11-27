# ich777/docker-cs2d-server (upstream image source)

## Source URL(s) + date
- https://raw.githubusercontent.com/ich777/docker-cs2d-server/master/Dockerfile
- https://raw.githubusercontent.com/ich777/docker-cs2d-server/master/scripts/start.sh
- https://raw.githubusercontent.com/ich777/docker-cs2d-server/master/scripts/start-server.sh
- https://api.github.com/repos/ich777/docker-cs2d-server (repo metadata)
- Fetched 2026-11-27 (master branch)

## What it is
- Generic CS2D dedicated-server image by ich777 (Unraid template source), `ghcr.io/ich777/cs2dserver`.
- Repo: `license: null`, `default_branch: master`, last pushed 2022-10-25, updated 2023-10-11, description null.

## Install/build steps and deps
- `FROM ich777/debian-baseimage` (no tag).
- `dpkg --add-architecture i386`, `apt-get install --no-install-recommends unzip libgtk2.0-0:i386`, `rm -rf /var/lib/apt/lists/*`.
- `mkdir $DATA_DIR`, `mkdir $SERVER_DIR`, `useradd -d $DATA_DIR -s /bin/bash $USER`, `chown -R $USER $DATA_DIR`, `ulimit -n 2048` (no runtime effect).
- `ADD /scripts/ /opt/scripts/`, `chmod -R 770 /opt/scripts/`.
- No ARG, EXPOSE, VOLUME, HEALTHCHECK. Labels: authors, source only.
- Game files are NOT in the image: `start-server.sh` downloads them at first start.

## Runtime deps
- unzip, libgtk2.0-0:i386 (32-bit GTK 2), i386 multiarch.
- Network to github.com (client zip) and www.unrealsoftware.de (dedicated zip) at start.

## Entrypoint/flow
- `ENTRYPOINT ["/opt/scripts/start.sh"]`, no CMD.
- `start.sh` (root): `usermod -u ${UID} ${USER}`; `groupmod -g ${GID}` (ignored on failure); `usermod -g ${GID}`; `umask ${UMASK}`; optional `/opt/custom/user.sh` or `/opt/scripts/user.sh`; `chown -R root:${GID} /opt/scripts`; `chmod -R 750 /opt/scripts`; `chown -R ${UID}:${GID} ${DATA_DIR}`; then `su ${USER} -c /opt/scripts/start-server.sh &` with SIGTERM trap.
- `start-server.sh` (as user):
  1. If `${SERVER_DIR}/CS2D` missing: wget `https://github.com/ich777/docker-cs2d-server/raw/master/cs/cs2d_1008_linux.zip` to `CS2D.zip`, unzip, rm. Client binary, not needed for a dedicated server.
  2. If `${SERVER_DIR}/cs2d_dedicated` missing: wget `http://www.unrealsoftware.de/files_pub/cs2d_dedicated_linux.zip` to `CS2D-dedicated.zip`, unzip -qo, rm. On failure: `sleep infinity`.
  3. If `FORCE_UPDATE == "true"`: moves server files to `Backup`, re-downloads both zips. Contains a malformed line `wget -q -nc ... -O http://www.unrealsoftware.de/...` (the URL is passed as the -O filename, no output name).
  4. `chmod -R ${DATA_PERM} ${DATA_DIR}`; `cd ${SERVER_DIR}`; run `${SERVER_DIR}/cs2d_dedicated ${GAME_PARAMS}`.

## Env vars (Dockerfile ENV)
| Name | Default | Use |
| --- | --- | --- |
| DATA_DIR | `/serverdata` | root data dir |
| SERVER_DIR | `${DATA_DIR}/serverfiles` | game dir |
| GAME_PARAMS | `""` | args to cs2d_dedicated |
| FORCE_UPDATE | `""` | `true` triggers the backup and re-download path |
| UMASK | `000` | umask |
| UID | `99` | runtime uid of USER |
| GID | `100` | runtime gid of USER |
| DATA_PERM | `770` | chmod on DATA_DIR |
| USER | `cs2d` | runtime user name |

## Ports
- None declared (no EXPOSE, no port in scripts). TrueCharts uses UDP 36963 (see truecharts file), not verified in upstream.

## Volumes/paths
- `/serverdata` (DATA_DIR), `/serverdata/serverfiles` (SERVER_DIR). No VOLUME instruction.
- Scripts `/opt/scripts` (root:GID, 750). Optional hook `/opt/custom/user.sh`.

## User/UID
- Build creates `cs2d`. Start-time root wrapper remaps to UID 99 / GID 100 and drops to `cs2d` via `su`. Not rootless.

## Healthcheck
- None.

## Version/asset naming
- Client zip name embeds `1008` (`cs2d_1008_linux.zip`). Dedicated zip is unversioned (`cs2d_dedicated_linux.zip`).

## Gotchas
- start.sh and start-server.sh need root and `usermod`/`chown`; incompatible with a non-root `USER` or read-only rootfs as written.
- Launch path is hard-wired to `cs2d_dedicated`.
- Repo has no license set and has not changed since 2023.
