# GitHub: ich777/docker-terraria-server, branch tshock (Dockerfile)

Source URL(s): https://raw.githubusercontent.com/ich777/docker-terraria-server/tshock/Dockerfile (fetched 2026-11-27)

## Dockerfile
- FROM `ich777/mono-baseimage`; LABEL source=https://github.com/ich777/docker-terraria-server.
- apt: `screen unzip` (no-install-recommends).
- Adds Microsoft package repo: wget `https://packages.microsoft.com/config/debian/13/packages-microsoft-prod.deb`, dpkg -i, apt install `aspnetcore-runtime-9.0`.
- gotty: wget `https://github.com/yudai/gotty/releases/download/v1.0.1/gotty_linux_amd64.tar.gz`, extracted to /usr/bin/ (web console).
- ENV defaults:
| var | default |
| --- | --- |
| DATA_DIR | /serverdata |
| SERVER_DIR | ${DATA_DIR}/serverfiles |
| GAME_VERSION | template |
| GAME_MOD | template |
| GAME_PARAMS | template |
| ENABLE_WEBCONSOLE | true |
| GOTTY_PARAMS | -w --title-format Terraria-TShock |
| UMASK | 000 |
| UID / GID | 99 / 100 |
| USER | terraria |
| DATA_PERM | 770 |
- RUN: mkdir $DATA_DIR and $SERVER_DIR; useradd -d $DATA_DIR -s /bin/bash $USER; chown; ulimit -n 2048.
- ADD scripts/ -> /opt/scripts/; ADD config/ -> /config/ (chmod 777 on /opt/scripts).
- ENTRYPOINT `["/opt/scripts/start.sh"]`. No EXPOSE, no USER directive.

## Runtime deps
- ASP.NET Core runtime 9.0 (aspnetcore-runtime-9.0), screen, unzip, gotty 1.0.1.
- Mono base image (`ich777/mono-baseimage`).

## Gotchas
- Microsoft repo URL pinned to Debian 13 (trixie) package config.
- Scripts/start logic not fetched.
