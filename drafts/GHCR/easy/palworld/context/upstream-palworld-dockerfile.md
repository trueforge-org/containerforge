# ich777/docker-steamcmd-server (palworld branch) Dockerfile

Source URL(s) + date: https://raw.githubusercontent.com/ich777/docker-steamcmd-server/palworld/Dockerfile (fetched 2026-11-27). Master branch summary is in ich777-docker-steamcmd-server.md (copied from shared cache).

## Dockerfile
- `FROM ich777/debian-baseimage` (no tag, implicit latest).
- apt-get update; install `--no-install-recommends -y` lib32gcc-s1, lib32stdc++6, xdg-user-dirs, libcurl4t64; rm /var/lib/apt/lists/*.
- mkdir $DATA_DIR, $STEAMCMD_DIR, $SERVER_DIR; `useradd -d $DATA_DIR -s /bin/bash $USER`; `chown -R $USER $DATA_DIR`; `ulimit -n 2048` in same RUN; `chmod -R 770 /opt/scripts/`.
- `ADD /scripts/ /opt/scripts/`.
- ENTRYPOINT ["/opt/scripts/start.sh"]; no CMD, EXPOSE, VOLUME, HEALTHCHECK, WORKDIR, or USER.
- LABEL authors admin@minenet.at; source https://github.com/ich777/docker-steamcmd-server.

## Env vars (Dockerfile defaults)
| Variable | Default |
| --- | --- |
| DATA_DIR | /serverdata |
| STEAMCMD_DIR | ${DATA_DIR}/steamcmd |
| SERVER_DIR | ${DATA_DIR}/serverfiles |
| GAME_ID | 2394010 |
| GAME_PARAMS | EpicApp=PalServer |
| GAME_PARAMS_EXTRA | -useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS |
| UPDATE_PUBLIC_IP | false |
| BACKUP | false |
| BACKUP_INTERVAL | 120 |
| BACKUPS_TO_KEEP | 12 |
| VALIDATE | "" |
| UMASK | 000 |
| UID | 99 (env only) |
| GID | 100 (env only) |
| USERNAME | "" |
| PASSWRD | "" |
| USER | steam (env only) |
| DATA_PERM | 770 |

## Runtime / user
- No USER instruction; UID/GID 99/100 are ENV only. Account name steam from ENV USER.
- Note: Dockerfile GAME_PARAMS default (EpicApp=PalServer) differs from chart GAME_PARAMS (port flags, -publiclobby); chart value overrides.

## Gotchas
- Image runs as root by default (no USER); chart runs root too.
- Steam game install and launch scripts (/opt/scripts/start.sh, start-server.sh) are in the shared cache summary ich777-docker-steamcmd-server.md.
