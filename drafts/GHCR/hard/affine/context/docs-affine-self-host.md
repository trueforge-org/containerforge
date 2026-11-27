# AFFiNE docs: Self-host AFFiNE (overview)

Source URL(s) + date: https://docs.affine.pro/self-host-affine (fetched 2026-11-27)

## Facts
- Docker Compose is the recommended deployment. Compose runs: AFFiNE server, migration job, Postgres, Redis, volumes, config together.
- Components: AFFiNE server (web app, API, sync, collaboration); Postgres (primary DB, back up); Redis (cache, background tasks, sync); blob storage (filesystem by default); configuration (Admin Panel + config); reverse proxy and HTTPS.
- Requirements (basic): at least 4 CPU cores, 2 GB RAM, storage for server, Postgres, blobs, config.
- Before first start: set persistent DB_DATA_LOCATION, UPLOAD_LOCATION, CONFIG_LOCATION; set strong DB_PASSWORD.
- Production: configure domain, HTTPS, server external URL before inviting users.
- Backups: Postgres database, uploaded blobs (filesystem storage), exported modified config from Admin Panel.
- Sub-pages listed: install (Docker Compose), configuration, upgrade, administer (naming, domain/HTTPS, backup, email, OAuth, Postgres, Redis, storage, indexer, AI), references (environment variables, docker-compose.yml), develop.
- Software requirements: Docker Compose, Postgres, Redis, persistent storage, HTTPS for production.
- Troubleshooting: `role "affine" does not exist` (see docs).
