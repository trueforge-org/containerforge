# Gokapi documentation (gokapi.readthedocs.io, latest)

**Source URL(s) + fetch date**
- https://gokapi.readthedocs.io/en/latest/ (index only)
- Fetched 2026-11-26

**What it is**
Gokapi docs index: file sharing with expiring links, file requests, multi-user, deduplication, optional end-to-end encryption, S3-compatible storage, CLI, REST API, CSS/JS customisation.

**What the index shows**
- Page sections (not fetched): `setup.html` (Installation, Running Gokapi, Initial Setup, Changing Configuration, Reverse Proxy, systemd, Docker migration from `DOCKER_NONROOT` to `docker --user`), `advanced.html` (Environment variables, Databases, CLI Tool, API, Automatic Deployment), `update.html` (Docker and native), `troubleshooting.html` (setup page CORS error, Docker container loses data after update, uploads fail behind a reverse proxy), `examples.html`.
- No env var table, port, paths or healthcheck details on the index.

**Contradictions with plan.md**
- None found on the index. Environment variable and port facts in plan.md are confirmed from the Go source (see github-forceu-gokapi.md), not from this page.
- Sub-pages `setup.html` and `advanced.html` were not fetched (budget); the `DOCKER_NONROOT` migration note is consistent with dockerentry.sh.
