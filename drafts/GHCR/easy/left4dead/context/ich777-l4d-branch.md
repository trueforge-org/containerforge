# ich777/docker-steamcmd-server (l4d branch)

## Source URL(s) + date
- https://raw.githubusercontent.com/ich777/docker-steamcmd-server/l4d/README.md
- https://raw.githubusercontent.com/ich777/docker-steamcmd-server/l4d/Dockerfile
- Fetched 2026-11-26. Per-game branch; differs from master (see ich777-docker-steamcmd-server.md).

## What it is
Unraid-oriented SteamCMD image; l4d branch installs and runs Left 4 Dead (Steam app 222840).

## Install/build steps
- `FROM ich777/debian-baseimage:bullseye_amd64`.
- `apt-get install --no-install-recommends lib32gcc-s1` (only this lib; master also installs lib32stdc++6 and lib32z1), then clean apt lists.
- Creates `/serverdata`, `/serverdata/steamcmd`, `/serverdata/serverfiles`; `useradd -d /serverdata -s /bin/bash steam`; `chown -R steam /serverdata`; `ulimit -n 2048` (no runtime effect).
- `ADD /scripts/ /opt/scripts/`; `chmod -R 770 /opt/scripts/`.
- `ENTRYPOINT ["/opt/scripts/start.sh"]`.

## Env vars (Dockerfile defaults)
| Name | Default |
| --- | --- |
| DATA_DIR | /serverdata |
| STEAMCMD_DIR | ${DATA_DIR}/steamcmd |
| SERVER_DIR | ${DATA_DIR}/serverfiles |
| GAME_ID | template |
| GAME_NAME | template |
| GAME_PARAMS | template |
| GAME_PORT | 27015 |
| VALIDATE | "" |
| UMASK | 000 |
| UID | 99 |
| GID | 100 |
| USERNAME | "" |
| PASSWRD | "" |
| USER | steam |
| DATA_PERM | 770 |

## README example
- GAME_ID `222840` (beta: `'222840 -beta YOURBRANCH'`), GAME_NAME `left4dead`, GAME_PORT `27015`, GAME_PARAMS `+maxplayers 4 +map l4d_farm04_barn`.
- Ports: `-p 27015:27015 -p 27015:27015/udp`.
- Volumes: `/path/to/steamcmd:/serverdata/steamcmd`, `/path/to/l4d:/serverdata/serverfiles`.
- Image tag: `ich777/steamcmd:l4d`.

## Runtime deps
- lib32gcc-s1; Steam network access at start.

## Entrypoint/flags
- Start flow identical in design to master start.sh/start-server.sh (srcds_run with `-game ${GAME_NAME} ${GAME_PARAMS} -console +port ${GAME_PORT}`). See master summary.

## Healthcheck
- None defined in Dockerfile.

## Gotchas
- Start script runs as root and remaps `steam` to UID/GID; not rootless, needs writable rootfs.
- README does not list VALIDATE default or SRCDS-specific details; GAME_NAME must be `left4dead`.
