# TrueCharts chart: spoolman (stable)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/spoolman/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `spoolman` v4.0.0, library `common` 32.8.5, appVersion 0.27.1, category `inventory`.
- Description: keep track of 3D-printer filament spools. Depends on postgresql (enabled).

## Image (values.yaml)
- repository: `ghcr.io/donkie/spoolman`
- tag: `0.27.1@sha256:1ebb4f6a62c2e72a07f18b07ebfdbd96322f5bc2eb72570af3088f68d7c393b1`
- pullPolicy: IfNotPresent

## Ports
| name | port | proto |
| --- | --- | --- |
| main | 8000 | http |

## Persistence
| name | mountPath |
| --- | --- |
| data | /data |
| logs | /logs |

## Env (workload.main containers.main) set by chart
| var | value |
| --- | --- |
| SPOOLMAN_HOST | 0.0.0.0 |
| SPOOLMAN_PORT | `{{ service.main.ports.main.port }}` (8000) |
| SPOOLMAN_DIR_DATA | `{{ persistence.data.mountPath }}` (/data) |
| SPOOLMAN_DIR_LOGS | `{{ persistence.logs.mountPath }}` (/logs) |
| SPOOLMAN_DB_TYPE | postgres |
| SPOOLMAN_DB_HOST | secretKeyRef `<release>-postgresqlcreds` key `plainhost` |
| SPOOLMAN_DB_PORT | 5432 |
| SPOOLMAN_DB_NAME | postgresql depconfig `spoolman` |
| SPOOLMAN_DB_USERNAME | postgresql depconfig `spoolman` |
| SPOOLMAN_DB_PASSWORD | secretKeyRef `<release>-postgresqlcreds` key `postgresql-password` |
| SPOOLMAN_DEBUG_MODE | true |

## Security context
- readOnlyRootFilesystem: false, runAsUser: 0, runAsGroup: 0 (chart default)

## Dependencies
- postgresql enabled, username `spoolman`, database `spoolman`.
