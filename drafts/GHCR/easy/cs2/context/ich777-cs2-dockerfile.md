# ich777/docker-steamcmd-server, branch cs2, Dockerfile

## Source URL(s) + date
- https://raw.githubusercontent.com/ich777/docker-steamcmd-server/cs2/Dockerfile (fetched 2026-11-27)
- Same content class as master (see ich777-docker-steamcmd-server.md in this folder for the shared flow). Only the cs2-branch differences are listed here.

## Install/build
- `FROM ich777/debian-baseimage:bullseye_amd64`
- `apt-get install --no-install-recommends lib32gcc-s1 lib32stdc++6 lib32z1 lsof libicu67`, then `rm -rf /var/lib/apt/lists/*`
- `LABEL org.opencontainers.image.authors` and `org.opencontainers.image.source` (`https://github.com/ich777/docker-steamcmd-server`)
- Creates `/serverdata`, `/serverdata/steamcmd`, `/serverdata/serverfiles`; `useradd -d /serverdata -s /bin/bash steam`; `chown -R steam /serverdata`
- `ADD /scripts/ /opt/scripts/`; `chmod -R 770 /opt/scripts/`
- `ENTRYPOINT ["/opt/scripts/start.sh"]`; no CMD, EXPOSE, VOLUME, HEALTHCHECK

## Env (Dockerfile defaults)
| Name | Default |
| --- | --- |
| DATA_DIR | `/serverdata` |
| STEAMCMD_DIR | `${DATA_DIR}/steamcmd` |
| SERVER_DIR | `${DATA_DIR}/serverfiles` |
| GAME_ID / GAME_NAME / GAME_PARAMS | `template` |
| GAME_PORT | `27015` |
| VALIDATE | `""` |
| UMASK | `000` |
| UID / GID | `99` / `100` |
| USERNAME / PASSWRD | `""` / `""` |
| USER | `steam` |
| DATA_PERM | `770` |

## Gotchas
- Differs from master: adds `lsof libicu67` to apt list.
- Container starts as root (start.sh remaps UID/GID with usermod/groupmod, then `su steam`). Not rootless.
