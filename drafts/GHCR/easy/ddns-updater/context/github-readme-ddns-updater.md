# Upstream README: ddns-updater

Source URL(s):
- https://raw.githubusercontent.com/qdm12/ddns-updater/master/README.md (fetched 2026-11-27; grep of Docker and config lines)

## Install (Docker)
- Images: `ghcr.io/qdm12/ddns-updater` and `qmcgaw/ddns-updater` (Docker Hub).
- Run: `docker run -d -p 8000:8000/tcp -v "$(pwd)"/data:/updater/data ghcr.io/qdm12/ddns-updater`
- Data dir: `data/` on host, mounted at `/updater/data`. Must be owned by UID 1000 (built-in user) and writable, or run with a different UID via a rebuild with `--build-arg UID=<uid>`.
- `data/config.json` must be readable by UID 1000.
- Config can be given as one-line JSON in env `CONFIG` (takes precedence over config.json). Without a bind-mounted `/updater/data`, `updates.json` is not persisted.

## Env (from README table, defaults)
| Name | Default | Note |
| --- | --- | --- |
| CONFIG | (empty) | JSON config, overrides file |
| LISTENING_ADDRESS | `:8000` | Web UI TCP port |
| HEALTH_SERVER_ADDRESS | `127.0.0.1:9999` | |
| HEALTH_HEALTHCHECKSIO_BASE_URL | `https://hc-ping.com` | |
| HEALTH_HEALTHCHECKSIO_UUID | (empty) | |
| DATADIR | `/updater/data` | |
| CONFIG_FILEPATH | `/updater/data/config.json` | |
| BACKUP_PERIOD | `0` | e.g. `72h15m` enables zip backups |
| BACKUP_DIRECTORY | `/updater/data` | |
| TZ | (empty) | e.g. `America/Montreal` |

## Ports and firewall
- TCP 8000 inbound for the WebUI.

## Healthcheck
- Built-in: DNS lookups verify all records are current. Reports unhealthy when public IP cannot be fetched; recovers on its own.

## Build args
| Arg | Default |
| --- | --- |
| UID | 1000 |
| GID | 1000 |
| VERSION | unknown |
| CREATED | an unknown date |
| COMMIT | unknown |

## Gotchas
- Docker image is scratch-based and about 12 MB.
- Running as root (`--user=0`) works but upstream advises against it.
