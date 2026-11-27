# itzg/docker-minecraft-server Dockerfile (commit 1ccd6a0954f6)

Source URL(s) + date:
- https://raw.githubusercontent.com/itzg/docker-minecraft-server/1ccd6a0954f6/Dockerfile (2026-11-27)

## What it is
Java Minecraft server image; base `eclipse-temurin:21-jre` by default (`ARG BASE_IMAGE`). Downloads server jars at runtime via `/start` scripts and mc-image-helper.

## Build steps / deps
- `FROM ${BASE_IMAGE}` (default eclipse-temurin:21-jre)
- `install-packages` and `setup-user` via `/build/run.sh` (BuildKit mount of `build/`)
- COPY sudoers from files/
- easy-add 0.8.6 (ADD from GitHub release), then:
  - restify 1.7.3
  - rcon-cli 1.6.7
  - mc-monitor 0.12.12
  - mc-server-runner 1.12.2
- mc-image-helper 1.39.0 tgz from GitHub releases to /usr/share; symlink /usr/bin/mc-image-helper
- Log4jPatcher 1.0.1 jar fetched from GitHub to /image/Log4jPatcher.jar

## Runtime
- ENTRYPOINT `["/start"]`
- VOLUME `/data`; WORKDIR `/data`; STOPSIGNAL SIGTERM
- Scripts: `scripts/start*` -> /; `bin/*` -> /usr/local/bin; `bin/mc-health` -> /health.sh; `files/*` -> /image; `files/auto` -> /auto
- `dos2unix /start* /auto/*`

## Env vars (ENV defaults)
| var | default |
| --- | --- |
| TYPE | VANILLA |
| VERSION | LATEST |
| EULA | "" (user must set) |
| UID | 1000 |
| GID | 1000 |

Comment: "End user MUST set EULA and change RCON_PASSWORD".

## Ports
- EXPOSE 25565

## Healthcheck
- `--start-period=1m --interval=5s --retries=24 CMD mc-health`

## Volumes/paths
- /data (VOLUME, WORKDIR); /image (files); /auto; /usr/share/mc-image-helper-*.

## User/UID
- UID/GID default 1000:1000 (ENV); setup-user in build.

## Gotchas
- Dockerfile has ARG FORCE_INSTALL_PACKAGES=1.
- Log4jPatcher is downloaded from GitHub at build time (not pinned by digest in the file).
