# Dispatcharr README (repo root)

Source URL: https://raw.githubusercontent.com/Dispatcharr/Dispatcharr/main/README.md (fetched 2026-11-27; NOT in urls.txt, fetched as the repo's main README)

## What it is
IPTV and stream management: M3U/Xtream Codes import, XMLTV/Schedules Direct EPG, output as M3U, XMLTV, Xtream Codes API, HDHomeRun. Multi-user access control.

## Quick run (from README)
```
docker run -d \
  -p 9191:9191 \
  ... \
  -v dispatcharr_data:/data
```
(Middle lines elided in extraction; port 9191 and /data volume confirmed.)

## Facts
- Web UI/API port: 9191.
- Data volume: /data.
- First-time setup: from private networks by default. For public IP, use `docker exec <container> python manage.py createsuperuser` or set `DISPATCHARR_SETUP_ALLOWED_IP`.
- Reverse proxy: set `DISPATCHARR_TRUSTED_PROXIES` (IP/CIDR or `none`).
- Reverse Proxy Auth setting only honors proxies in an explicit `DISPATCHARR_TRUSTED_PROXIES`.
- Compose files live under `docker/` (incl. docker-compose.dev.yml).

## Gotchas
- Docs site (https://dispatcharr.github.io/Dispatcharr-Docs) returned only the JS-rendered shell (nav titles: Setup, User Guide, Advanced, FAQ/Troubleshooting, API, Plugins); no body text recovered.
