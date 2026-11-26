# nocodb/nocodb README

**Source:** https://raw.githubusercontent.com/nocodb/nocodb/master/README.md (fetched 2026-11-26)

## What it is
- No-code spreadsheet-style database UI. Views: Grid, Gallery, Form, Kanban, Calendar.
- Sharing public/private with optional password. RBAC at multiple levels.
- Integrations: Slack, Discord, Mattermost; AWS SES, SMTP, MailerSend; S3, GCS, Minio.
- REST APIs and SDK; JWT or social-auth tokens.
- License: Sustainable Use License (`./LICENSE`).

## Docker run (per page)
| Setup | Image | Port | Volume | Env vars |
|---|---|---|---|---|
| SQLite | nocodb/nocodb:latest | 8080:8080 | `$(pwd)/nocodb` -> /usr/app/data/ | none |
| Postgres | nocodb/nocodb:latest | 8080:8080 | same | NC_DB, NC_AUTH_JWT_SECRET |

- Container name `noco`, detached.
- NC_DB format: `pg://host.docker.internal:5432?u=root&p=password&d=d1`
- SQLite default when NC_DB unset.

## Auto-upstall (production)
- `bash <(curl -sSL http://install.nocodb.com/noco.sh) <(mktemp)`
- Stack: NocoDB + PostgreSQL + Redis + Minio + Traefik (Let's Encrypt); re-run upgrades.

## Port / access
- 8080; `http://localhost:8080/dashboard`

## Build from source
- Pointer only: `.github/CONTRIBUTING.md`. Frontend under `packages/nc-gui`.
- Standalone binaries (macOS, Linux, Windows; arm64/x64) from get.nocodb.com for local testing only.
