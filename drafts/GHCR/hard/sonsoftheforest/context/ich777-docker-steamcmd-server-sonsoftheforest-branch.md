# ich777/docker-steamcmd-server, branch sonsoftheforest, Dockerfile
Source URL: https://raw.githubusercontent.com/ich777/docker-steamcmd-server/sonsoftheforest/Dockerfile (fetched 2026-11-27; branch differs from master summary in ich777-docker-steamcmd-server.md)

## Build
- `FROM ich777/winehq-baseimage`
- LABEL org.opencontainers.image.source=https://github.com/ich777/docker-steamcmd-server
- RUN apt-get install lib32gcc-s1 winbind xvfb screen; rm /var/lib/apt/lists/*
- RUN mkdir DATA_DIR, STEAMCMD_DIR, SERVER_DIR; useradd -d $DATA_DIR -s /bin/bash $USER; chown -R $USER $DATA_DIR; ulimit -n 2048
- ADD /scripts/ /opt/scripts/; chmod -R 770 /opt/scripts/
- ENTRYPOINT ["/opt/scripts/start.sh"]

## Env (Dockerfile defaults)
| env | default |
| --- | --- |
| DATA_DIR | /serverdata |
| STEAMCMD_DIR | ${DATA_DIR}/steamcmd |
| SERVER_DIR | ${DATA_DIR}/serverfiles |
| GAME_ID | "" |
| GAME_PARAMS | "" |
| GAME_PORT | 27015 |
| VALIDATE | "" |
| UMASK | 000 |
| UID | 99 |
| GID | 100 |
| USERNAME | "" |
| PASSWRD | "" |
| USER | steam |
| DATA_PERM | 770 |

## User/UID
- Dockerfile creates user `steam` (home DATA_DIR); UID/GID env default 99/100 (not applied by the Dockerfile itself).

## Gotchas
- Base is winehq-baseimage (Wine), unlike master branch steamcmd image.
- Dockerfile ends without a trailing newline (no functional effect).
