# Docker Hub joplin/server

## Source URL(s) + date
- https://hub.docker.com/v2/repositories/joplin/server/ (2026-11-26)
- https://hub.docker.com/v2/repositories/joplin/server/tags?page_size=10 (2026-11-26)

## What it is
- Official Joplin Server images. Namespace `joplin`, repo `server`, type `image`, active, public.
- Description: "Official Joplin Server Docker Images."
- `last_updated` 2026-11-16. `star_count` 307, `pull_count` 17792707.
- Total tags: 180.

## Tags (first page, sorted as returned)
| Tag | Arch | Pushed |
| --- | --- | --- |
| latest | amd64, arm64 | 2026-11-16 |
| 3.7.6 | amd64, arm64 | 2026-11-16 |
| amd64-3.7.6, amd64-3.7, amd64-3, amd64-latest | amd64 | 2026-11-16 |
| arm64-3.7.6, arm64-3.7, arm64-3, arm64-latest | arm64 | 2026-11-16 |

- Manifest list digest for `latest` and `3.7.6`: `sha256:1cd9097ec3f788ba9813b7907dd8d525c834b93c725da1add189bfd08f746cf0`.
- Docs (full_description): tags are `latest`, `beta`, major (`2`, `2-beta`), minor, patch.

## Runtime / config (from full_description)
- Default port 22300. Default DB is SQLite (test only).
- Env file based run: `docker run --env-file .env -p 22300:22300 joplin/server:latest`.
- Postgres mode: `DB_CLIENT=pg`, `POSTGRES_PASSWORD`, `POSTGRES_DATABASE`, `POSTGRES_USER`, `POSTGRES_PORT=5432`, `POSTGRES_HOST`. Alternative: `POSTGRES_CONNECTION_STRING=postgresql://user:pass@host:5432/joplin`.
- Database and user must already exist; server does not create them.
- Item content storage: default in DB. Optional `STORAGE_DRIVER=Type=Filesystem; Path=/path/to/dir`.
- Migration: `STORAGE_DRIVER_FALLBACK=Type=Database; Mode=ReadAndWrite` (or ReadAndClear).
- Reverse proxy (Apache/Nginx) optional.

## Gotchas
- Docker Hub `latest` and `3.7.6` are multi-arch. `amd64-*`/`arm64-*` tags are single arch.
- Docker Hub page does not list 3.7.24; upstream release 3.7.24 exists on GitHub (see github-joplin-release-latest.md).
