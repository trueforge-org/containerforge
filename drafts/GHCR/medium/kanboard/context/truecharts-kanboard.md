# TrueCharts chart: kanboard

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/kanboard/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- "Kanboard is a free and open source Kanban project management software." Chart version 22.0.0, `appVersion: 1.2.58`. Keywords: kanboard, kanban.
- Dependency `common` 32.8.5 (oci://oci.trueforge.org/truecharts).
- Sources: ghcr.io/kanboard/kanboard, github.com/kanboard/kanboard.

## Image
- Repository `ghcr.io/kanboard/kanboard`
- Tag `"v1.2.58@sha256:51a912ecd3b6df0cca2cfb521edb2cb92462c59fff427a4938465178b1f54d19"`, pullPolicy IfNotPresent.

## Security
- runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false.

## Ports
| Name | Port | Target |
| --- | --- | --- |
| main | 10015 | 80 |

## Env vars (chart)
| Name | Value |
| --- | --- |
| MAIL_CONFIGURATION | false |
| LOG_DRIVER | stdout |
| DB_DRIVER | postgres |
| DB_NAME | depconfig postgresqlDatabase (`kanboard`) |
| DB_USERNAME | depconfig postgresqlUsername (`kanboard`) |
| DB_PORT | 5432 |
| DB_PASSWORD | secretKeyRef `<release>-postgresqlcreds` key `postgresql-password` |
| DB_HOSTNAME | secretKeyRef `<release>-postgresqlcreds` key `plainhost` |

## Persistence
| Name | Mount |
| --- | --- |
| data | `/var/www/app/data` |
| ssl | `/etc/nginx/ssl` |

## Dependencies
- postgresql enabled (user `kanboard`, db `kanboard`).

## Gotchas
- Chart pins v1.2.58; the upstream Dockerfile fetched is v1.2.57 (see GitHub file). Chart uses `DB_*` env names, which are not in the upstream Dockerfile.
