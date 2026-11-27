# TrueCharts chart: bookorbit

**Source URL(s):** https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/bookorbit/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `bookorbit` v4.1.0, `appVersion: 3.10.0`, category `media`, train `stable`.
- Description: "A self-hosted library and reading platform for ebooks, PDFs, audiobooks, and comics."
- Library dependency: `common` 32.8.5 (`oci://oci.trueforge.org/truecharts`).
- Chart dependency: `postgresql` (enabled; depconfig user and db `bookorbit`).
- Sources: `ghcr.io/bookorbit/bookorbit`, github bookorbit/bookorbit, trueforge chart path.

## Image (values.yaml)
- Repository: `ghcr.io/bookorbit/bookorbit`
- Tag: `3.10.0@sha256:39686c8937725ddaa7485fffaeead6bcd62589ff052df7785fcf8bd8d85c21f1`
- pullPolicy: IfNotPresent

## Ports
| Name | Port | Protocol |
| --- | --- | --- |
| main | 3000 | http |

## Probes (HTTP `/api/v1/health`)
- liveness, readiness, startup: `path: /api/v1/health`.

## Env (workload.main.podSpec.containers.main.env)
| Var | Value |
| --- | --- |
| NODE_ENV | production |
| PORT | service port (3000) |
| POSTGRES_HOST | secretKeyRef `{{Release}}-postgresqlcreds` key `plainhost` |
| POSTGRES_PORT | 5432 |
| POSTGRES_USER | depconfig `postgresqlUsername` (bookorbit) |
| POSTGRES_PASSWORD | secretKeyRef `{{Release}}-postgresqlcreds` key `postgresql-password` |
| POSTGRES_DB | depconfig `postgresqlDatabase` (bookorbit) |
| APP_URL | http://localhost:3000 |
| CLIENT_URL | http://localhost:3000 |
| LIBRARY_BROWSE_ROOT | persistence books mountPath (`/books`) |
| BOOK_DOCK_PATH | persistence bookdock mountPath (`/data/book-dock`) |
| JWT_SECRET | secretKeyRef `env-secrets` key `JWT_SECRET` |
| SETUP_BOOTSTRAP_TOKEN | secretKeyRef `env-secrets` key `SETUP_BOOTSTRAP_TOKEN` |
| NODE_MAX_OLD_SPACE_SIZE | "2048" |

## Persistence
| Name | Mount |
| --- | --- |
| data | /data |
| bookdock | /data/book-dock |
| books | /books |

## Dependencies: PostgreSQL extensions
- initdb postInitApplicationSQL: `uuid-ossp`, `pg_trgm`, `unaccent`, `vector` (pgvector). Comment: default CNPG image ships these.

## Secrets (chart defaults, placeholders)
- `env-secrets`: `JWT_SECRET: changeme_changeme`, `SETUP_BOOTSTRAP_TOKEN: changeme`.

## Gotchas
- Chart runs as root (`runAsUser 0`); not the ContainerForge model.
- Chart's data mount `/data` and books mount `/books` are the paths upstream uses.
