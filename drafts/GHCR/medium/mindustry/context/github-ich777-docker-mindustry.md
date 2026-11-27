# ich777/docker-mindustry (Dockerfile, scripts/start.sh, scripts/start-server.sh; master)

Source URL(s) + date:
- https://raw.githubusercontent.com/ich777/docker-mindustry/master/Dockerfile (2026-11-27)
- https://raw.githubusercontent.com/ich777/docker-mindustry/master/scripts/start.sh (2026-11-27)
- https://raw.githubusercontent.com/ich777/docker-mindustry/master/scripts/start-server.sh (2026-11-27)

## What it is
Debian-based image that runs the Mindustry dedicated server (`server-release.jar`) in a `screen` session with optional gotty web console.

## Build steps / deps
- Base: `ich777/debian-baseimage`
- apt (no-install-recommends): curl, screen, default-jre; rm lists
- gotty 1.0.1 tarball from GitHub releases (`gotty_linux_amd64.tar.gz`) extracted to /usr/bin (amd64 only, hard-coded)
- `mkdir $DATA_DIR`; `useradd -d $DATA_DIR -s /bin/bash mindustry`; chown; `ulimit -n 2048` (no effect in a RUN line)
- `ADD /scripts/ /opt/scripts/`; chmod -R 770

## Runtime
- ENTRYPOINT `["/opt/scripts/start.sh"]`
- start.sh runs as root: `usermod -u $UID`, `groupmod -g $GID`, `usermod -g $GID`, `umask $UMASK`, optional `/opt/custom/user.sh` or `/opt/scripts/user.sh`, chown `/opt/scripts` to root:GID (750) and `$DATA_DIR` to UID:GID, then `su $USER -c /opt/scripts/start-server.sh` in background; trap SIGTERM; loops on wait.
- start-server.sh: determines latest version from `api.github.com/repos/Anuken/Mindustry/releases/latest` (tag_name) if GAME_V=latest; downloads `https://github.com/Anuken/Mindustry/releases/download/v${GAME_V}/server-release.jar` with wget; marker file `mindustryinstalled-v<ver>`; on version mismatch removes old jar and marker; `sleep infinity` on download failure.
- Launch: `screen -S Mindustry -L -Logfile $DATA_DIR/masterLog.0 -d -m java -jar $DATA_DIR/server-release.jar ${EXTRA_PARAMS}name ${SRV_NAME},host,${GAME_PARAMS}`
- If ENABLE_WEBCONSOLE=true: `/opt/scripts/start-gotty.sh` (NOT in fetched files); `screen -S watchdog -d -m /opt/scripts/start-watchdog.sh` (NOT fetched); then `tail -F $DATA_DIR/masterLog.0`.

## Env vars (Dockerfile ENV defaults)
| var | default |
| --- | --- |
| DATA_DIR | /mindustry |
| GAME_V | latest |
| SRV_NAME | DockerMindustry |
| GAME_PARAMS | "" |
| EXTRA_PARAMS | "config " |
| ENABLE_WEBCONSOLE | true |
| GOTTY_PARAMS | -w --title-format Mindustry |
| UMASK | 000 |
| UID | 99 |
| GID | 100 |
| DATA_PERM | 770 |
| USER | mindustry |

## Ports
- None EXPOSEd in Dockerfile. Game uses 6567 (chart). Web console port not set in fetched files (gotty default).

## Volumes/paths
- /mindustry (DATA_DIR): jar, marker files, masterLog.*, .screenrc in ~ (written by start-server.sh), .wget-hsts removed.
- /opt/scripts, /opt/custom/user.sh (optional hook).

## User/UID
- Container starts as root; start.sh remaps user `mindustry` to UID 99 / GID 100 and runs the server as that user via `su`.

## Config files
- None fetched. Server is configured via command-line `name,host` and EXTRA_PARAMS; `config` keyword in EXTRA_PARAMS.

## Healthcheck
- None.

## Version/asset naming
- Release asset: `server-release.jar` under tag `v<GAME_V>`.
- Latest version via GitHub API; if API fails, `LAT_V` is empty.

## Arch
- gotty binary is amd64 only (`gotty_linux_amd64`).

## Gotchas
- start.sh and start-server.sh depend on a GitHub API call and on `wget` (Dockerfile does not install wget explicitly; curl is installed).
- Dockerfile ENV GAME_V default "latest" (chart overrides to a digest-suffixed string).
- `ulimit -n 2048` in a RUN line does not persist.
- Runs as root at start; not rootless.
