# TrueCharts streammaster values.yaml
Source URL: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/streammaster/values.yaml (fetched 2026-11-27)

## Image
- repository `ghcr.io/carlreid/streammaster`, tag `0.15.0@sha256:20cb6360594d26b6056e6fdc1d3c541d94b5d44da784267426b0cbe6ad4dbade`, pullPolicy IfNotPresent

## Security
- runAsNonRoot false, readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0

## Ports
| service | port | notes |
| --- | --- | --- |
| main | 7095 | HTTP UI/API (DEFAULT_PORT) |
| sslport | 7096 | enabled (DEFAULT_SSL_PORT) |

## Env (workload main)
| env | value |
| --- | --- |
| DEFAULT_PORT | 7095 |
| DEFAULT_SSL_PORT | 7096 |
| BACKUP_VERSIONS_TO_KEEP | 5 |
| POSTGRES_DB | dependencies.postgresql.depconfig.postgresqlDatabase (`streammaster`) |
| POSTGRES_USER | depconfig.postgresqlUsername (`streammaster`) |
| POSTGRES_PASSWORD | secretKeyRef `<release>-postgresqlcreds` key postgresql-password |
| POSTGRES_HOST | secretKeyRef `<release>-postgresqlcreds` key plainhost |

## Dependencies
- dependencies.postgresql enabled: true (chart-level Postgres dependency; Chart.yaml lists only `common` in its direct dependency list)

## Persistence
| name | mountPath |
| --- | --- |
| config | /config |
| logos | /config/tv-logos |
