# truecharts teedy (chart version 21.1.0, appVersion 1.12.0)

Source URL(s) + date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/teedy/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/teedy/Chart.yaml
- Fetched 2026-11-27

## What it is
- `name: teedy`, `appVersion: 1.12.0`, `version: 21.1.0`, `type: application`
- Description: "Teedy is an open source, lightweight document management system for individuals and businesses."

## Image (values.yaml)
- repository: `docker.io/sismics/docs`
- tag: `v1.12@sha256:29ce750d44fd7de8ab995d77aa2bb50978f4ba0862e6aa827bf67517d8758c7b`
- pullPolicy: IfNotPresent

## Ports
| name | port | targetPort | protocol |
| --- | --- | --- | --- |
| main | 10100 | 8080 | (not set) |

## Persistence
- `data`: enabled, mountPath `/data`

## Dependencies
- `postgresql` enabled; depconfig user `teedyuser`, database `teedydb`

## Env (workload.main container `main`)
| key | value |
| --- | --- |
| DOCS_DEFAULT_LANGUAGE | "eng" |
| DOCS_BASE_URL | "" |
| DOCS_SMTP_HOSTNAME | "" |
| DOCS_SMTP_PORT | 0 |
| DOCS_SMTP_USERNAME | "" |
| DOCS_SMTP_PASSWORD | secretKeyRef `env-secrets` / `DOCS_SMTP_PASSWORD` |
| DOCS_ADMIN_EMAIL_INIT | "" |
| DOCS_ADMIN_PASSWORD_INIT | secretKeyRef `env-secrets` / `DOCS_ADMIN_PASSWORD_INIT` |
| DATABASE_USER | `teedyuser` (from dependency) |
| DATABASE_PASSWORD | secretKeyRef `<Release>-postgresqlcreds` / `postgresql-password` |
| DATABASE_URL | secretKeyRef `<Release>-postgresqlcreds` / `jdbc` |

Secret `env-secrets` (chart defaults, empty): DOCS_ADMIN_PASSWORD_INIT "", DOCS_SMTP_PASSWORD "".

## Probes / security
- No probes set. No securityContext set in values.yaml (chart defaults).

## Gotchas
- Chart pins `v1.12`; the Docker Hub tag list confirms `v1.12` (2026-11-23).
- Chart maps service 10100 to container 8080; `/data` is the data volume.
- Chart expects DATABASE_URL (JDBC) from a postgres secret, so postgresql is required.
