# Taxel PlexTraktSync README (main branch)

## Source URL(s) + date
- https://raw.githubusercontent.com/Taxel/PlexTraktSync/main/README.md (fetched 2026-11-27)
- Same as https://github.com/Taxel/PlexTraktSync/blob/main/README.md

## Docker compose (from README)
```
image: ghcr.io/taxel/plextraktsync
command: sync
restart: on-failure:2
volumes: ./config:/app/config
environment: PUID=1000, PGID=1000, TZ=Europe/Tallinn
```

## Healthcheck (optional, from README)
- `test: ["CMD", "plextraktsync", "healthcheck"]`, interval 60s, timeout 10s, start_period 30s, retries 3
- Scans log for ERROR/CRITICAL in the last hour; unhealthy if found

## Scheduling
- Run `plextraktsync sync` via cron or docker scheduler (README example: Ofelia with `@every 6h`, `docker exec`)

## Auth
- `plextraktsync login` (Plex, asks for missing credentials; 2FA prompt) and `plextraktsync trakt-login` (device flow; redirect URI `urn:ietf:wg:oauth:2.0:oob`)
- Config files go in `/app/config` (mapped volume); on NAS, move credentials into the mapped folder

## Gotchas
- Credentials must be created inside the container or placed in the mapped `/app/config` before running sync.
