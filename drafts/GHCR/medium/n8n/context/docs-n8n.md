# n8n docs (docs.n8n.io): self-hosting pages

Source URL(s) + date:
- https://docs.n8n.io (2026-11-27, main page)
- https://docs.n8n.io/hosting/configuration/environment-variables/ (2026-11-27, follow-up)
- https://docs.n8n.io/hosting/installation/docker/ (2026-11-27, follow-up; marked "outdated", points to Docker Compose)

What it is: n8n documentation. Main page is a getting-started index (fair-code workflow automation with AI features). Docs index available at llms.txt; any page available as `.md`.

Install (Docker, from the outdated page):
- `docker volume create n8n_data`
- Mount `-v n8n_data:/home/node/.n8n` to persist data (encryption keys, logs, source-control assets even with PostgreSQL)
- Postgres: `-e DB_TYPE=postgresdb` plus DB connection env vars
- Recommended method on the site: Docker Compose (n8n-hosting repo has compose configs)

Env vars: the environment-variables page in the static HTML contains only the section index (Basic configuration, Binary data, Credentials, Database, Deployment, Endpoints, Executions, Logs, Queue mode, Security, Task runners, etc.) and "File-based configuration": `_FILE` suffix supported on certain variables, plus a config file option. Individual variable names and defaults are not in the fetched text (JS-rendered tables).
- Names confirmed by fetched text: `DB_TYPE`, `DB_POSTGRESDB_*` (indirectly, via docker example).
- Not confirmed by these pages: N8N_PORT, N8N_ENCRYPTION_KEY, N8N_USER_FOLDER, N8N_CONFIG_FILES (chart uses N8N_USER_FOLDER and N8N_LOG_FILE_LOCATION; see truecharts-n8n.md).

Ports: none stated in fetched text (upstream Dockerfile: 5678/tcp).

Volumes/paths: `/home/node/.n8n` (docker install page).

Gotchas: docs pages are JS-rendered; tables did not come through. Do not invent variable names from these pages.
