# ich777/docker-openttd-server Dockerfile + OpenTTD release

Source URL(s) + date: https://raw.githubusercontent.com/ich777/docker-openttd-server/master/Dockerfile ; https://github.com/OpenTTD/OpenTTD/releases/latest (HTML alternative, API returned 403) (fetched 2026-11-27)

## Dockerfile
- `FROM ich777/debian-baseimage` (no tag, implicit latest).
- apt: unzip, xz-utils, curl, screen, libgomp1, libglib2.0-0 (--no-install-recommends); rm -rf /var/lib/apt/lists/*.
- gotty v1.0.1 (linux amd64 tar.gz from github yudai/gotty) extracted to /usr/bin/, archive removed.
- `mkdir $DATA_DIR`, `mkdir $SERVER_DIR`; `useradd -d $SERVER_DIR -s /bin/bash $USER`; `chown -R $USER $DATA_DIR`; `ulimit -n 2048`; `chmod -R 770 /opt/scripts/`.
- `ADD /scripts/ /opt/scripts/`.
- ENTRYPOINT ["/opt/scripts/start.sh"]; no CMD, EXPOSE, VOLUME, HEALTHCHECK, WORKDIR, or USER.
- LABEL authors admin@minenet.at; source https://github.com/ich777/docker-openttd-server.

## Env vars (Dockerfile defaults)
| Variable | Default |
| --- | --- |
| DATA_DIR | /serverdata |
| SERVER_DIR | ${DATA_DIR}/serverfiles |
| GAME_PARAMS | template |
| GAME_PORT | 3979 |
| GAME_VERSION | latest |
| ENABLE_WEBCONSOLE | true |
| GOTTY_PARAMS | -w --title-format OpenTTD |
| COMPILE_CORES | (empty) |
| GFX_PK_V | latest |
| UMASK | 000 |
| UID | 99 (env only) |
| GID | 100 (env only) |
| DATA_PERM | 770 |
| USER | openTTD |

## Runtime / user
- No USER instruction; UID/GID 99/100 set as ENV. User openTTD created with home $SERVER_DIR, shell /bin/bash.
- Web console via gotty when ENABLE_WEBCONSOLE=true.

## Release (GitHub HTML alternative)
- Latest: 15.3 (marked Latest), published 04 Apr 2026, commit 14ec60f. Asset names not loaded (page error). Asset count shown: 2.
- Chart's sample URL in urls.txt: cdn.openttd.org/openttd-releases/15.3/openttd-15.3-linux-generic-amd64.tar.xz (binary, not fetched).

## Gotchas
- Upstream image has no USER; runs as root by default (chart also root).
- Actual game install is driven by scripts in /opt/scripts (start.sh) which were not fetched; GAME_VERSION/GAME_PARAMS semantics come from chart and Dockerfile env.
- OpenTTD wiki server docs not obtained (wiki.openttd.org/en returned 404; wiki root had no server facts).
