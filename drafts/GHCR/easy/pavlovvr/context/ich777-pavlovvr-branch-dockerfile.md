# ich777 docker-steamcmd-server, pavlovvr branch Dockerfile

## Source URL(s) + date
- https://raw.githubusercontent.com/ich777/docker-steamcmd-server/pavlovvr/Dockerfile (fetched 2026-11-27)
- Base for the master branch: see `ich777-docker-steamcmd-server.md`

## What it is
Pavlov VR server image built on the SteamCMD base, branch `pavlovvr`.

## Build steps
- `FROM ich777/debian-baseimage`
- LABEL source: https://github.com/ich777/docker-steamcmd-server
- apt install (no-install-recommends): `lib32gcc-s1 curl gdb libc++1`, then `rm -rf /var/lib/apt/lists/*`
- Fix: `cp /usr/lib/llvm-14/lib/libc++.so.1.0 /usr/lib/x86_64-linux-gnu/libc++.so` (Pavlov does not accept linked libc++.so)
- `ADD /scripts/ /opt/scripts/`, `chmod -R 770 /opt/scripts/`
- Creates dirs `/serverdata`, `/serverdata/steamcmd`, `/serverdata/serverfiles`; `useradd -d /serverdata -s /bin/bash steam`; `chown -R steam /serverdata`; `ulimit -n 2048` (in RUN)

## Env (Dockerfile defaults)
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

## Entrypoint
- `ENTRYPOINT ["/opt/scripts/start.sh"]`

## User/UID
- USER steam (UID env 99, GID env 100); no USER directive, so container runs as root by default

## Ports
- None exposed in Dockerfile (GAME_PORT 27015 env only)

## Volumes/paths
- `/serverdata`, `/serverdata/steamcmd`, `/serverdata/serverfiles`

## Gotchas
- GAME_ID/GAME_NAME/GAME_PARAMS defaults are placeholders ("template"); chart sets GAME_ID 622970
- Pavlov needs the libc++.so symlink-copy fix above
