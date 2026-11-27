# TrueCharts chart: tracks (stable)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/tracks/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `tracks` v11.0.0, library `common` 32.8.5, appVersion `latest`, category Productivity.
- Web-based todo app implementing GTD (Ruby on Rails).

## Image (values.yaml)
- repository: `ghcr.io/tracksapp/tracks`
- tag: `latest@sha256:73202a73e9f77a83801e199540d374e101aa1dd7bcdeddbc7b8d5105b837c9b5`
- pullPolicy: IfNotPresent

## Ports
| name | port | targetPort | proto |
| --- | --- | --- | --- |
| main | 3000 | 3000 | tcp |

## Persistence
- `persistence: {}` (none defined).

## Env (workload.main containers.main)
| var | value |
| --- | --- |
| BUNDLE_WITHOUT | "" |
| DATABASE_ENCODING | utf8 |
| DATABASE_HOST | 10.0.0.10 (hardcoded example IP) |
| DATABASE_NAME | tracks |
| DATABASE_PASSWORD | secret `env-secrets` key DATABASE_PASSWORD |
| DATABASE_PORT | "3306" |
| DATABASE_TYPE | mysql2 |
| DATABASE_USERNAME | tracks |
| RAILS_ENV | production |

Secret `env-secrets`: DATABASE_PASSWORD "password".

## Security context (chart values)
- readOnlyRootFilesystem: false, runAsGroup 0, runAsUser 0.

## Dependencies
- None in chart (external MySQL/MariaDB expected; DATABASE_HOST is a fixed IP).
