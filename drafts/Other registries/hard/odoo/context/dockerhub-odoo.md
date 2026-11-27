# Docker Hub: library/odoo

## Source URL(s) + date
- https://hub.docker.com/v2/repositories/library/odoo/ (fetched 2026-11-27, JSON)
- https://hub.docker.com/v2/repositories/library/odoo/tags?page_size=10 (fetched 2026-11-27, JSON)

## Repo facts
- Name `odoo`, namespace `library` (official image).
- Description: Odoo (formerly OpenERP), suite of open-source business apps.
- Last updated 2026-11-25; pull count 57,928,560; stars 1523.
- Maintained by Odoo (github.com/odoo/docker).

## Tags (10 most recent, count 234 total)
| Tag | Last updated | Arches seen |
| --- | --- | --- |
| latest | 2026-11-25 | amd64, ppc64le, arm64, unknown (attestation) |
| 20.0-20261123 | 2026-11-25 | same |
| 20.0 | 2026-11-25 | same |
| 20 | 2026-11-25 | same |
| 19.0-20261123 | 2026-11-25 | same |
| 19.0 | 2026-11-25 | same |
| 19 | 2026-11-25 | same |
| 18.0-20261124 | 2026-11-25 | same |
| 18.0 | 2026-11-25 | same |
| 18 | 2026-11-25 | same |

- Full-description tag map (from repo README): `20.0-20261123`, `20.0`, `20`, `latest` built from odoo/docker commit ec04c28 `20.0/Dockerfile`.

## Full description (Docker Hub) facts
- Requires a running PostgreSQL server; example `postgres:15` with POSTGRES_USER/PASSWORD/DB=odoo.
- Persist with volume at `/var/lib/odoo`; mount addons at `/mnt/extra-addons`; port `8069`.
- Container alias `db` expected by default entrypoint (`--link db:db`).

## Gotchas
- Pinned chart digest is `20.0@sha256:6709a...`; latest/20.0 tags differ from the pinned Dockerfile commit 0ea197e (see github-odoo-docker.md).
