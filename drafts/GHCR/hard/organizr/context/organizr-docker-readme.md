# Source: Organizr/docker-organizr README (master)

Source URL(s) + date: https://raw.githubusercontent.com/Organizr/docker-organizr/master/README.md (fetched 2026-11-27, 5 KB)

## Usage (from README)
```
docker create --name=organizr -v /path/to/data:/config -e PGID=1000 -e PUID=1000 -p 80:80 -e branch="v2-master" ghcr.io/organizr/organizr
```

## Env vars
| Var | Default | Notes |
| --- | --- | --- |
| PUID | 1000 (example) | user ID; doc says ensure data volume dir ownership |
| PGID | 1000 (example) | group ID |
| branch | v2-master | v2-master and master -> v2-master branch; v2-develop, develop, dev -> dev branch |

## Ports / volumes
- Port 80 (`-p 80`). Volume /config (Organizr config).

## Platforms
- linux-amd64 (x86-64), linux-arm64, linux-arm-v7 (armhf).

## Base / runtime
- "Based on Alpine Linux with an s6 overlay."
- Organizr is NOT contained inside the image; the container fetches the Organizr code (latest of the chosen branch) at start. Built-in updater does not break installs; restart to update.
- `.original` and `.rework` backups created when files the container changes are replaced.

## Migration
- Drop-in replacement for organizrtools/organizr-v2. Nginx healthcheck config moved to /config/nginx/site-confs/healthcheck; install dir moved from /config/www/Dashboard to /config/www/organizr.
- Uses unix socket for PHP exclusively.

## Shell / logs
- `docker exec -it organizr /bin/bash`; `docker logs -f organizr`.

## Gotchas
- Setup of accounts and tabs is via web UI.
