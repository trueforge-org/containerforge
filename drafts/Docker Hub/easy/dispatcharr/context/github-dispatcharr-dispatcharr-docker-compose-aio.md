# Dispatcharr/Dispatcharr docker/docker-compose.aio.yml (main branch)

Source URL(s) + fetch date:
- https://raw.githubusercontent.com/Dispatcharr/Dispatcharr/main/docker/docker-compose.aio.yml · 2026-11-26

## Facts
- Single service `dispatcharr`, `restart: unless-stopped`, image `ghcr.io/dispatcharr/dispatcharr:latest` (build block commented out).
- Port `9191:9191`. Volume `dispatcharr_data` at `/data`.
- Env: `DISPATCHARR_ENV=aio`, `REDIS_HOST=localhost`, `CELERY_BROKER_URL=redis://localhost:6379/0`, `DISPATCHARR_LOG_LEVEL=info`. Others commented (see github-dispatcharr-dispatcharr.md).
- No healthchecks, no depends_on, no secrets.
