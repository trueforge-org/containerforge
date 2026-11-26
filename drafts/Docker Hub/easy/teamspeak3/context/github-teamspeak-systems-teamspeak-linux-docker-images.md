# TeamSpeak-Systems/teamspeak-linux-docker-images (official Docker image source)

**Source URL(s)** (fetched 2026-11-26)
- https://raw.githubusercontent.com/TeamSpeak-Systems/teamspeak-linux-docker-images/88586dc62959fd95700968a42eab6cf093cd9f86/alpine/Dockerfile
- https://raw.githubusercontent.com/TeamSpeak-Systems/teamspeak-linux-docker-images/88586dc62959fd95700968a42eab6cf093cd9f86/alpine/entrypoint.sh
- Pinned to commit `88586dc62959fd95700968a42eab6cf093cd9f86` (the commit the draft references).

## What it is
Upstream build for the official `teamspeak` Docker Hub image (TeamSpeak 3 server, Alpine variant). This is the Dockerfile the draft traces `teamspeak:3.13.9` to.

## Install/build steps and build deps (alpine/Dockerfile)
- `FROM alpine:3.23`
- Build args: `TEAMSPEAK_URL=https://files.teamspeak-services.com/releases/server/3.13.9/teamspeak3-server_linux_alpine-3.13.9.tar.bz2`, `TEAMSPEAK_CHECKSUM=82f58acdb2cffafa993d43ecc884133b9c6d59d15ec0dafcd7bbcd0d476a8510` (the **alpine** tarball, not the glibc amd64 one used in the plan).
- RUN 1 (`set -eux`): `apk` install (no cache) `ca-certificates libstdc++ su-exec libpq`; create group `ts3server` GID 9987 and user `ts3server` UID 9987 (home `/var/ts3server`, `-H`, `/sbin/nologin`); `install` dirs `/var/ts3server`, `/var/run/ts3server`, `/opt/ts3server` owned `ts3server:ts3server`, mode 775.
- RUN 2 (`set -eux`): temporary `.fetch-deps` (tar); wget URL to `server.tar.bz2`; `sha256sum -c -`; extract `--strip-components=1` into `/opt/ts3server`; delete archive; `apk del .fetch-deps`; move `/opt/ts3server/*.so` and `/opt/ts3server/redist/*` to `/usr/local/lib`; `ldconfig /usr/local/lib`; remove `/opt/ts3server/redist`.
- `ENV PATH` extended with `:/opt/ts3server`; `ENV TS3SERVER_FILETRANSFER_PORT=30033`.
- LABELs: `com.teamspeak.title="TeamSpeak 3 Server"`, `com.teamspeak.version="3.13.9"`, `com.teamspeak.description="TeamSpeak 3 Server on Alpine Linux"`.

## Runtime deps
Alpine packages: `ca-certificates`, `libstdc++`, `su-exec`, `libpq` (libpq present for PostgreSQL plugin).

## Binaries/entrypoint/CLI flags
- `COPY entrypoint.sh /opt/ts3server`; `ENTRYPOINT ["entrypoint.sh"]`; `CMD ["ts3server"]`.
- Entrypoint (`sh`, `set -e`): if arg is `ts3server` and uid is 0, `chown -R ts3server /var/ts3server` then re-exec via `su-exec ts3server`. If arg is `ts3server`, it appends `inifile=/var/run/ts3server/ts3server.ini` as the last argument. Ends with `exec "$@"`.
- `file_env` helper: any var can be supplied as `<VAR>_FILE` (Docker secrets). Setting both forms prints an error and exits 1. Applied to `TS3SERVER_DB_HOST`, `TS3SERVER_DB_USER`, `TS3SERVER_DB_PASSWORD`, `TS3SERVER_DB_NAME`.

## Env vars (generated ini mapping, from entrypoint.sh)
Env var names are the ones the entrypoint reads; the ini key is in parentheses.

| Env var | Default in entrypoint | ini key |
| --- | --- | --- |
| TS3SERVER_LICENSEPATH | none | licensepath |
| TS3SERVER_QUERY_PROTOCOLS | `raw` | query_protocols |
| TS3SERVER_QUERY_TIMEOUT | `300` | query_timeout |
| TS3SERVER_QUERY_SSH_RSA_HOST_KEY | `ssh_host_rsa_key` | query_ssh_rsa_host_key |
| TS3SERVER_IP_ALLOWLIST | `query_ip_allowlist.txt` | query_ip_allowlist |
| TS3SERVER_IP_BLOCKLIST | `query_ip_blocklist.txt` | query_ip_blocklist |
| TS3SERVER_DB_PLUGIN | `ts3db_sqlite3` | dbplugin |
| TS3SERVER_DB_PLUGINPARAMETER | `/var/run/ts3server/ts3db.ini` | dbpluginparameter |
| TS3SERVER_DB_SQLPATH | `/opt/ts3server/sql/` | dbsqlpath |
| TS3SERVER_DB_SQLCREATEPATH | `create_sqlite` | dbsqlcreatepath |
| TS3SERVER_DB_CONNECTIONS | `10` | dbconnections |
| TS3SERVER_DB_CLIENTKEEPDAYS | `30` | dbclientkeepdays |
| TS3SERVER_LOG_PATH | `/var/ts3server/logs` | logpath |
| TS3SERVER_LOG_QUERY_COMMANDS | `0` | logquerycommands |
| TS3SERVER_LOG_APPEND | `0` | logappend |
| TS3SERVER_SERVERQUERYDOCS_PATH | `/opt/ts3server/serverquerydocs/` | serverquerydocs_path |
| TS3SERVER_QUERY_PORT | `10011` | query_port |
| TS3SERVER_FILETRANSFER_IP | none | filetransfer_ip |
| TS3SERVER_FILETRANSFER_PORT | `30033` | filetransfer_port |
| TS3SERVER_DEFAULT_VOICE_PORT | `9987` | default_voice_port |
| TS3SERVER_QUERY_SSH_PORT | `10022` | query_ssh_port |
| TS3SERVER_QUERY_IP | only if set | query_ip |
| TS3SERVER_VOICE_IP | only if set | voice_ip |
| TS3SERVER_QUERY_SSH_IP | only if set | query_ssh_ip |
| TS3SERVER_SERVERADMIN_PASSWORD | only if set | serveradmin_password |
| TS3SERVER_MACHINE_ID | only if set | machine_id |
| TS3SERVER_QUERY_SKIPBRUTEFORCECHECK | only if set | query_skipbruteforcecheck |
| TS3SERVER_HINTS_ENABLED | only if set | hints_enabled |

`ts3db.ini` (`[config]` section) is written from `TS3SERVER_DB_HOST` (single-quoted), `TS3SERVER_DB_PORT` (default `3306`), `TS3SERVER_DB_USER`, `TS3SERVER_DB_PASSWORD`, `TS3SERVER_DB_NAME`, `socket=` (empty), `TS3SERVER_DB_WAITUNTILREADY` (default `30`).

## Ports
`EXPOSE 9987/udp 10011 30033` (voice, query, file transfer). SSH query 10022 is used only when `ssh` is in query protocols.

## Volumes/paths and persistent data
- `VOLUME /var/ts3server/`, `WORKDIR /var/ts3server/`. Data, logs and licence live there.
- Generated ini files: `/var/run/ts3server/ts3server.ini` and `/var/run/ts3server/ts3db.ini`.
- Binaries under `/opt/ts3server`; shared libs moved to `/usr/local/lib`.
- Note: `licensepath` has no entrypoint default (the docs say `/var/ts3server/`).

## User/UID & permissions
- User/group `ts3server` UID/GID 9987. The Dockerfile has **no USER instruction**; the entrypoint starts as root, chowns `/var/ts3server`, then drops to `ts3server` via `su-exec`.

## Config files and formats
ini (`key=value`), one per line, blank lines stripped and whitespace trimmed (see above).

## Healthcheck/readiness endpoints
None in the Dockerfile.

## Version/release info and asset naming
- Version 3.13.9 (LABEL). Alpine asset: `teamspeak3-server_linux_alpine-3.13.9.tar.bz2`.
- The glibc amd64 asset the plan uses (`teamspeak3-server_linux_amd64-3.13.9.tar.bz2`) is a different file with a different checksum; this upstream file does not fetch it.

## Arch support
Upstream Dockerfile is alpine (musl) only, from the alpine tarball. The docs page says only amd64 is published.

## Gotchas
- The upstream image is musl/Alpine. The plan's glibc `amd64` tarball and checksum `35049b...` are not what upstream uses, so the plan's checksum cannot be confirmed from this source. See README for the contradiction note.
- Upstream runs as root at start and drops privileges, while the ContainerForge plan starts as `apps` (568). Entrypoint's `chown -R` is therefore not needed. `DOWNSTREAM` not relevant.
- `TS3SERVER_IP_ALLOWLIST`/`BLOCKLIST` are the env names the entrypoint reads. The Docker Hub page documents `TS3SERVER_IP_WHITELIST`/`BLACKLIST` (see the docs-teamspeak-dockerhub note in dockerhub-teamspeak.md).
- `TS3SERVER_LICENSE` is not read by the entrypoint at all; the binary reads it (documented on Docker Hub).
