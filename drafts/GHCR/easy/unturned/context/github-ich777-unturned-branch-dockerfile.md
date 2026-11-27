# Upstream Dockerfile: ich777/docker-steamcmd-server, branch `unturned`

Source URL(s) + date: https://raw.githubusercontent.com/ich777/docker-steamcmd-server/unturned/Dockerfile (fetched 2026-11-27). Differs from master (master base is ich777/debian-baseimage:bullseye_amd64 per cached summary).

## Build
- `FROM ich777/debian-baseimage` (no tag pinned in this branch file).
- Labels: authors admin@minenet.at; source https://github.com/ich777/docker-steamcmd-server.
- apt: `lib32gcc-s1 unzip` (`--no-install-recommends`), rm lists.
- mkdir $DATA_DIR, $STEAMCMD_DIR, $SERVER_DIR; `useradd -d /serverdata -s /bin/bash steam`; `chown -R steam /serverdata`; `ulimit -n 2048` (no runtime effect).
- ADD /scripts/ /opt/scripts/; chmod -R 770 /opt/scripts/.
- ENTRYPOINT ["/opt/scripts/start.sh"]. No CMD, EXPOSE, VOLUME, HEALTHCHECK.

## ENV defaults (branch)
| Env | Default |
| --- | --- |
| DATA_DIR | /serverdata |
| STEAMCMD_DIR | ${DATA_DIR}/steamcmd |
| SERVER_DIR | ${DATA_DIR}/serverfiles |
| GAME_ID | template |
| GAME_NAME | template |
| GAME_PARAMS | template |
| GAME_PORT | 27015 |
| VALIDATE | "" |
| ROCKET_MOD | "true" |
| ROCKET_URL | https://ci.rocketmod.net/job/Rocket.Unturned/lastSuccessfulBuild/artifact/Rocket.Unturned/bin/Release/Rocket.zip |
| ROCKET_FORCE_UPDATE | "" |
| UMASK | 000 |
| UID | 99 |
| GID | 100 |
| USERNAME | "" |
| PASSWRD | "" |
| USER | steam |
| DATA_PERM | 770 |

## Gotchas
- GAME_NAME/GAME_PARAMS are not used by the branch start-server.sh (it launches Unturned_Headless directly).
- Base image unpinned in this file.
- Same 32-bit libs story as master but only lib32gcc-s1 is installed here (no lib32stdc++6 / lib32z1).
