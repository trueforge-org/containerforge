# standardnotes.com self-hosting help: web app + Docker pages

Source URL(s): https://standardnotes.com/help/self-hosting/web-app ; https://standardnotes.com/help/self-hosting/docker (WebFetch 2026-11-26)

## Web app container (web-app guide)
- Image: `standardnotes/web` (no tag given; defaults to latest).
- Container listens on port 80. Example: `docker run -d -p 3000:80 standardnotes/web` -> http://localhost:3000
- Env vars: none documented on this page (see help/self-hosting/configuration-options, not fetched).
- Volumes: none documented, none used in example.
- Backend: none documented on this page (sync server setup in getting-started and docker guides).
- User/UID, read-only rootfs, healthcheck: not specified.
- Prereq: Docker installed.

## Self-hosted server stack (docker guide, "v2")
- 4 containers total (legacy had 13); primary container ~570 MB RAM.
- Server default port 3000; files server default port 3125; change via `ports` in `server` service of docker-compose.yml.
- Config: `.env` based on `.env.sample` (minimum values). Full env list in `docker/docker-entrypoint.sh` of standardnotes/server repo (not fetched).
- `KEYS` section values: `openssl rand -hex 32`. `DB_PASSWORD` in .env.
- `PUBLIC_FILES_SERVER_URL` = public URL of files server (example http://10.0.1.2:3125).
- Compose: `MYSQL_ROOT_PASSWORD` and `MYSQL_PASSWORD` must match `DB_PASSWORD` (`openssl rand -hex 12`). `localstack_bootstrap.sh` must be executable in working dir.
- Start: `docker compose pull && docker compose up -d`; update: `docker compose down`, refresh files, pull, up.
- Logs: logs/*.log and logs/*.err.
- Web app at app.standardnotes.com cannot be used with self-hosted server; HTTPS needs reverse proxy.
- Tested on Ubuntu 22.04, 2 GB RAM, 1 CPU.
