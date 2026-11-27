# Upstream: timothepoznanski/poznote (repo page, README, latest release)

Source URL(s) + date:
- https://github.com/timothepoznanski/poznote (2026-11-27, HTML; license text not extracted)
- https://raw.githubusercontent.com/timothepoznanski/poznote/5db51e94dfa0f6f204f267505153cf5fd143feb2/README.md (2026-11-27)
- https://api.github.com/repos/timothepoznanski/poznote/releases/latest: 403. Alternative https://github.com/timothepoznanski/poznote/releases/latest (HTML) -> "Release 6.161.0"
- https://github.com/timothepoznanski/poznote/releases/tag/6.153.0: not fetched (covered by plan.md; budget)

What it is: self-hosted note-taking / knowledge base (web editor, attachments, snapshots, backups, optional OIDC). Multi-arch image (amd64, arm64). Compose files in repo: docker-compose.yml, docker-compose.rootless.yml, .env.template.

Version: latest release seen 2026-11-27 is `6.161.0`. The chart appVersion is `6.160.1`. The plan.md says latest `6.159.0`, see conflicts below.

Rootless (README): uid/gid `1000`; host data dir must be chowned to 1000 before first start.

Env vars (README, Change Settings section, partial):
- POZNOTE_OIDC_CLIENT_ID, POZNOTE_OIDC_CLIENT_SECRET, POZNOTE_OIDC_DISABLE_NORMAL_LOGIN
- POZNOTE_MCP_PORT, POZNOTE_DEBUG (optional runtime overrides), POZNOTE_MCP_AUTH_TOKEN and other POZNOTE_MCP_* variables
- POZNOTE_PHP_FPM_MAX_CHILDREN (default 10), POZNOTE_PHP_MEMORY_LIMIT (MB, default 512), POZNOTE_LISTEN_PORT (default 80; only needed with network_mode host)
- POZNOTE_SETTINGS_PASSWORD (empty by default)

Ports: web 80 (default image) or 8080 (rootless); MCP port via POZNOTE_MCP_PORT (default not extracted).

Install: compose-based (`docker compose pull`, `docker compose up -d`) with `.env` from `.env.template`.

License: README/plan say MIT. The repo page did not expose the license text in the fetched HTML; Dockerfile label says "Open Source". Not verified here.

Gotchas: README version references and the Dockerfile label are not an SPDX id; use the LICENCE file in the repo (named LICENCE per plan.md) to confirm.
