# ich777/docker-steamcmd-server (longvinter branch)

## Source URL(s) + date
- https://raw.githubusercontent.com/ich777/docker-steamcmd-server/longvinter/README.md
- https://raw.githubusercontent.com/ich777/docker-steamcmd-server/longvinter/Dockerfile
- Fetched 2026-11-26. Per-game branch; differs from master (see ich777-docker-steamcmd-server.md).

## What it is
Unraid-oriented SteamCMD image; longvinter branch installs and runs Longvinter (Steam app 1639880).

## Install/build steps
- `FROM ich777/debian-baseimage` (no tag pinned).
- `apt-get install --no-install-recommends lib32gcc-s1 lib32stdc++6 git-lfs`, then clean apt lists.
- Creates `/serverdata`, `/serverdata/steamcmd`, `/serverdata/serverfiles`; `useradd -d /serverdata -s /bin/bash steam`; `chown -R steam /serverdata`; `ulimit -n 2048` (no runtime effect).
- `ADD /scripts/ /opt/scripts/`; `chmod -R 770 /opt/scripts/`.
- `ENTRYPOINT ["/opt/scripts/start.sh"]`.

## Env vars (Dockerfile defaults)
| Name | Default |
| --- | --- |
| DATA_DIR | /serverdata |
| STEAMCMD_DIR | ${DATA_DIR}/steamcmd |
| SERVER_DIR | ${DATA_DIR}/serverfiles |
| GAME_ID | 1639880 |
| GAME_NAME | "" |
| GAME_PARAMS | "" |
| GAME_PORT | 27016 |
| VALIDATE | "" |
| UMASK | 000 |
| UID | 99 |
| GID | 100 |
| USERNAME | "" |
| PASSWRD | "" |
| USER | steam |
| DATA_PERM | 770 |

## README example
- Initial server name "Longvinter Docker", initial password "Docker" (README text).
- Env table lists only STEAMCMD_DIR, SERVER_DIR, GAME_PARAMS (empty), UID 99, GID 100, GAME_PORT 27016. Table header says "CS:Source" (copy-paste from other README).
- Ports: `-p 27016:27016/udp`. Volumes: `/path/to/steamcmd:/serverdata/steamcmd`, `/path/to/longvinter:/serverdata/serverfiles`. Image tag `ich777/steamcmd:longvinter`.

## Runtime deps
- lib32gcc-s1, lib32stdc++6, git-lfs (git-lfs is listed only on this branch).
- Steam network access at start.

## Entrypoint/flags
- Same start.sh flow as master (see master summary). GAME_NAME is empty by default here (master start-server expects srcds style `-game`); GAME_PARAMS empty.

## Healthcheck
- None defined.

## Gotchas
- GAME_NAME defaults to empty; check the start script's use before relying on srcds_run for this game.
- Run example maps only the game port (UDP 27016).
- Start script runs as root and remaps `steam` to UID/GID; needs writable rootfs.
