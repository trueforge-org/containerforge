# Docker Hub: teamspeak (official image)

**Source URL(s)** (fetched 2026-11-26): https://hub.docker.com/_/teamspeak

## What it is
Official TeamSpeak 3 server image, maintained by TeamSpeak developers (HuppiN, achimklittich). Issues go to https://github.com/TeamSpeak-Systems/teamspeak-linux-docker-images.

## Tags and arch
- Tags: `3.13`, `3.13.9`, `latest` (all Alpine-based).
- Architecture: **amd64 only**.

## Running it
- View licence: `docker run -e TS3SERVER_LICENSE=view teamspeak`
- Run: `docker run -p 9987:9987/udp -p 10011:10011 -p 30033:30033 -e TS3SERVER_LICENSE=accept teamspeak`
- After start, the server query password and server admin privilege key are generated and must be written down (only shown in logs).
- Compose example: `teamspeak` with a `mariadb` service, `TS3SERVER_DB_PLUGIN: ts3db_mariadb`, `TS3SERVER_DB_SQLCREATEPATH: create_mariadb`, `TS3SERVER_DB_HOST: db`, `TS3SERVER_DB_WAITUNTILREADY: 30`, `TS3SERVER_LICENSE: accept`.

## Env vars
| Variable | Default | Description |
| --- | --- | --- |
| `TS3SERVER_LICENSE` | none stated | `view` shows agreement, `accept` accepts |
| `TS3SERVER_LICENSEPATH` | `/var/ts3server/` | dir for `licensekey.dat` |
| `TS3SERVER_DB_PLUGIN` | none stated | DB type |
| `TS3SERVER_DB_PLUGINPARAMETER` | none stated | param to DB plugin |
| `TS3SERVER_DB_SQLPATH` | `/opt/ts3server/sql/` | SQL files |
| `TS3SERVER_DB_SQLCREATEPATH` | none stated | init scripts, relative to SQL path |
| `TS3SERVER_DB_CONNECTIONS` | `10` | 2 to 100 |
| `TS3SERVER_DB_CLIENTKEEPDAYS` | none stated | days unused identities kept (guests pruned, grouped users not) |
| `TS3SERVER_IP_WHITELIST` | none stated | file of IPs exempt from flood protection |
| `TS3SERVER_IP_BLACKLIST` | none stated | file of IPs always blocked from ServerQuery |
| `TS3SERVER_LOG_PATH` | `/var/ts3server/logs/` | log folder |
| `TS3SERVER_LOG_QUERY_COMMANDS` | none stated | `1` logs every query command |
| `TS3SERVER_LOG_APPEND` | none stated | `0` suggested |
| `TS3SERVER_QUERY_PROTOCOLS` | none stated | `raw` (10011/tcp) and/or `ssh` (10022/tcp); empty disables |
| `TS3SERVER_QUERY_TIMEOUT` | `300` | inactivity timeout; zero/negative disables |
| `TS3SERVER_QUERY_SSH_RSA_HOST_KEY` | none stated | `ssh_host_rsa_key`, created if missing |

`TS3SERVER_DB_WAITUNTILREADY` appears only in the compose example (`30`), undocumented.

## Ports
9987/udp (voice), 10011 (raw ServerQuery), 30033 (file transfer), 10022/tcp (SSH query, only if enabled).

## Volumes
- Data in `/var/ts3server/`. Bind-mount example: `-v /my/own/datadir:/var/ts3server/`.
- `licensekey.dat` may be mounted at `/var/ts3server/licensekey.dat`. Needed for more than 1 virtual server with 32 slots.

## Licence
Must set `TS3SERVER_LICENSE=accept` to start the server.

## Gotchas
- Do not add untrusted IPs to the whitelist (flood risk).
- `TS3SERVER_LOG_QUERY_COMMANDS=1` can create extremely large logs; keep at `0`.
- Users are responsible for the licences of included software.
- Docs use `IP_WHITELIST`/`IP_BLACKLIST`, while the upstream entrypoint reads `TS3SERVER_IP_ALLOWLIST`/`TS3SERVER_IP_BLOCKLIST` (see github-teamspeak-systems-teamspeak-linux-docker-images.md).
