# docs.maintainerr.info: installation and configuration

**Source URL(s):** https://docs.maintainerr.info/installation/ ; https://docs.maintainerr.info/configuration/
**Fetched:** 2026-11-26 (docs at version 3.33.0)

## Installation

### General
- Docker is the supported install method. Images for amd64 and arm64 at `maintainerr/maintainerr` and `ghcr.io/maintainerr/maintainerr`.
- Data location in the container: `/opt/data`. A Docker volume is strongly encouraged.
- Development tags: `:development` (`ghcr.io` and Docker Hub). Moving back from development to stable is not supported.

### Ports
- Default web port 6246 (mapped `6246:6246`).

### User and permissions
- The configured `user:group` is the runtime user; host data files are owned by it.
- Default UID:GID `1000:1000`. The host data directory must be readable and writable by that UID:GID (e.g. `chown -R 1000:1000 /opt/data`).
- Examples use `user: 1000:1000` (Compose), `-u 1000:1000` (run), `runAsUser`/`runAsGroup`/`fsGroup: 1000` (Kubernetes). No PUID/PGID variables are documented.
- Rootful Quadlet: `User=1000`, `Group=1000`. Rootless: `UserNS=keep-id:uid=1000,gid=1000`.

### Volumes
- Required: host data bound to `/opt/data`.
- Optional: `/data/media` bound to `/data/media` (leftover-folder cleanup; must match the path Radarr/Sonarr report; runtime user must write it).

### Compose example (abridged)
- `image: ghcr.io/maintainerr/maintainerr:latest`, `user: 1000:1000`, bind `<host>:/opt/data`, optional `/data/media:/data/media`, `TZ=Europe/Brussels`, `ports: 6246:6246`, `restart: unless-stopped`.
- Run example: `docker run -d --name maintainerr -e TZ=... -v <host>:/opt/data -v /data/media:/data/media -u 1000:1000 -p 6246:6246 --restart unless-stopped ghcr.io/maintainerr/maintainerr:latest`.
- Update: pull, stop and remove the container, run again.

### Podman Quadlet
- `~/.config/containers/systemd/maintainerr.container`, `Volume=%h/maintainerr/data:/opt/data:Z`, `PublishPort=6246:6246`, optional `AutoUpdate=registry`; `Restart=always`, `TimeoutStartSec=900`.

### Kubernetes
- Single-replica Deployment, Service on 6246, PVC (ReadWriteOnce, 1Gi) at `/opt/data`. Liveness `/api/health/live` (initial 30s, period 30s). Readiness `/api/health/ready` (initial 10s, period 10s).

### Health endpoints (under `/api/health`)
- `GET /api/health/live`: 200 while the process runs (no DB check).
- `GET /api/health/ready`: DB `SELECT 1`; 200 if reachable, 503 if not.
- `GET /api/health`: alias for `/ready`.
- Prefixed by `BASE_PATH` when set (e.g. `/maintainerr/api/health/ready`).
- Built-in image `HEALTHCHECK` uses `/opt/app/healthcheck.sh`, which honours `BASE_PATH` and `UI_PORT`.

### Environment variables (official list; no others supported)
| Variable | Default | Purpose |
| --- | --- | --- |
| TZ | host timezone | Log date formatting |
| UI_HOSTNAME | 0.0.0.0 | Listen host (`::` for IPv6) |
| UI_PORT | 6246 | Listen port |
| BASE_PATH | (empty) | Subfolder for reverse proxy; surrounding slashes trimmed |
| LOG_LEVEL | info | Override log level (debug, verbose, info, warn, error, fatal) |
| GITHUB_TOKEN | (empty) | Higher GitHub API rate limits |
| CORS_ALLOWED_ORIGINS | (empty) | Comma-separated origins for cross-origin API calls |
| TELEMETRY | (empty) | `off` disables the anonymous weekly usage report |
| SPORTARR_NET | (empty) | `on` allows artwork from sportarr.net |

- Not stated: amd64 CPU requirement (x86-64-v2 is in the repo README, not here). No PUID/PGID.

## Configuration
- All configuration is in the web UI ("All configuration is done inside the application"). No config files.
- Service connections (media server, Radarr/Sonarr/Sportarr, Seerr/Ombi, download client, metadata, Tautulli/Tracearr, Streamystats) are set under `Services`. General, Logs, Jobs and About are under `Settings`. General has hostname, an API key (reserved for future use) and display language.
- The page does not state the data directory layout (SQLite path) or log file path.
- No BASE_PATH setting in the UI; env var only (see installation).
- No built-in login: anyone who can reach the app can read stored credentials. Put an authenticating reverse proxy in front for internet exposure (Security & Authentication page not fetched).
- Service URLs must start with `http://` or `https://`; trailing slashes are stripped.
- Plex on a different Docker network: add the LAN address to Plex's "Custom server access URLs"; "Secure connections" should be "Preferred", not "Required", for a local instance.
- qBittorrent 403 after login from a different IP: whitelist the Maintainerr IP or subnet in qBittorrent's Web UI security settings.
- **File-deletion and storage safety:** no dry-run setting on this page. "Delete downloaded data" removes files with the torrent (turn off for cross-seeding; shared files are kept while another torrent uses them). Cleanup runs only for media Radarr or Sonarr deletes, and only for actions that delete files (unmonitor and quality change never remove downloads). Sonarr cleanup runs only for whole-show deletions. Seeding: client's own goal first; else fallback ratio after 23 hours; 14-day seeders are removed at any ratio. Removal is best-effort. Exclusion tag `dnd` is off by default.
- Ombi: "Force delete Ombi request" is per rule group.
