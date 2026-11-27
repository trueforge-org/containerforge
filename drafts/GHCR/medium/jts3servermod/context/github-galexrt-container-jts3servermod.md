# Upstream: galexrt/container-jts3servermod (commit 4ecf611553251cdafcb9176aeff42c2edaa609e0)

Source URL(s) + date: https://raw.githubusercontent.com/galexrt/container-jts3servermod/4ecf611553251cdafcb9176aeff42c2edaa609e0/{Dockerfile,entrypoint.sh,README.md} (fetched 2026-11-27). Repo API api.github.com/repos/galexrt/container-jts3servermod returned 403 (not retried). Release page v20240301-172535-248 not fetched.

## What it is
- Container packaging of JTS3ServerMod (Stefan1200), a Java TeamSpeak 3 bot/server mod.
- Image tags per README: `main` (latest main build) and `vYYYYmmdd-HHMMSS-NNN` (build date).
- Also published to quay.io/galexrt/jts3servermod.

## Build (Dockerfile)
- `FROM openjdk:8-jre-buster`
- ARGs: BUILD_DATE, REVISION, JTS3_USER=3000, JTS3_GROUP=3000, TINI_ARCH=amd64, ARCH="".
- ENV: TINI_VERSION=v0.19.0, JTS3_DIR=/jts3servermod, JTS3_JAVA_ARGS=-Xmx256M, TINI_ARCH, ARCH.
- ADD tini binary `https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-${TINI_ARCH}` and its `.sha256sum`; verifies sha256, moves to /tini (chmod 755).
- Creates group/user `jts3servermod` (uid/gid from JTS3_USER/JTS3_GROUP), `apt-get upgrade`, installs `unzip`.
- Downloads `https://www.stefan1200.de/dlrequest.php?file=jts3servermod&type=.zip` (no checksum in Dockerfile), unzips, moves `JTS3ServerMod` dir to /jts3servermod.
- Touches `JTS3ServerMod_InstanceManager.log`, chowns /jts3servermod to jts3servermod.
- Removes `tools`, `readme*`, `documents`, `changelog.txt`. Copies `config` to `default_config`.
- Cleans apt lists and /tmp.
- `COPY entrypoint.sh /entrypoint.sh` (chmod 755).

## Runtime
- `USER "$JTS3_USER"` (3000), `WORKDIR "${JTS3_DIR}"` (/jts3servermod).
- `VOLUME ["${JTS3_DIR}/config"]`.
- `ENTRYPOINT ["/tini", "--"]`, `CMD ["/entrypoint.sh"]`.

## Entrypoint (entrypoint.sh)
- `JTS3_LOG` default `JTS3ServerMod_InstanceManager.cfg`.
- If `$JTS3_DIR/config/` is empty: copy `$JTS3_DIR/default_config/*` into it.
- `cd "$JTS3_DIR"`, then `exec java "$JTS3_JAVA_ARGS" -jar "$JTS3_DIR/JTS3ServerMod.jar" -log "$JTS3_LOG" "$@"`.

## Runtime deps
- Java 8 (JRE). Upstream docs: Java SE 8 or newer; "Version 8 is recommended". TS3 server 3.0 or newer.
- tini v0.19.0 (PID 1).

## Env vars
| Var | Default | Use |
| --- | --- | --- |
| JTS3_DIR | /jts3servermod | install dir |
| JTS3_USER | 3000 | runtime uid (build ARG) |
| JTS3_GROUP | 3000 | runtime gid (build ARG) |
| JTS3_JAVA_ARGS | -Xmx256M | passed as ONE quoted argv entry |
| JTS3_LOG | JTS3ServerMod_InstanceManager.cfg | `-log` argument |
| TINI_VERSION | v0.19.0 | build |
| TINI_ARCH | amd64 | build; tini binary suffix |
| ARCH | "" | build; empty means dpkg arch |

## Ports
- None. TS3 query is outbound (upstream docs: bot connects to TS3 telnet query port).

## Volumes/paths
- `/jts3servermod/config` (VOLUME; populated from default_config on empty start).
- `/jts3servermod/logs` used by chart (not created by Dockerfile).
- `/jts3servermod/default_config` (seed copy).

## User/UID
- uid/gid 3000:3000 (build ARG). Mounted host dirs need chown 3000:3000 (README).

## Config files
- `JTS3ServerMod_InstanceManager.cfg` (instance list, one config dir per bot instance) and `JTS3ServerMod_server.cfg` (per-instance settings), per upstream docs.
- Other config files (advertising, record, idle, welcome messages) are unicode without BOM by default.

## Healthcheck
- None in Dockerfile.

## Version/asset naming
- Upstream tag scheme `vYYYYmmdd-HHMMSS-NNN`. Chart pins `v20240301-172535-248`.
- Stefan1200 zip has no version in the URL (always latest).

## Arch
- `TINI_ARCH` build arg (default amd64). `ARCH` build arg optional.

## Gotchas
- Base `openjdk:8-jre-buster` (Debian buster, EOL image).
- `JTS3_JAVA_ARGS` is quoted in entrypoint: multiple JVM flags in one variable become a single argument and will break.
- Stefan1200 zip download is unpinned and has no checksum.
- `JTS3_LOG` is used as `-log` file; chart sets it to a `.cfg` path.
- Dockerfile does `apt-get upgrade` at build (unpinned).
