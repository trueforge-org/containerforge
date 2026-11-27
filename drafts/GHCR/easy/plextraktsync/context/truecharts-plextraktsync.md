# TrueCharts plextraktsync chart

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/plextraktsync/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/plextraktsync/Chart.yaml
- Fetched 2026-11-27

## What it is
- "Two-way-sync between trakt.tv and Plex Media Server." Chart 14.0.0, appVersion 0.35.23, keywords Tools-Utilities, MediaApp-Other
- Dependency: `common` 32.8.5 (oci://oci.trueforge.org/truecharts)
- Chart sources: ghcr.io/taxel/plextraktsync, github Taxel/PlexTraktSync

## Image (values.yaml)
- repository: `ghcr.io/taxel/plextraktsync` (GHCR, no Docker Hub source)
- tag: `0.35.23@sha256:071d8211100a2fb66cd0f47103e54d489ab4dce73e532f71b22ea8475e30ed91`

## Security context
- runAsNonRoot false, runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false

## Chart values (plextraktsync.*)
| Key | Default |
| --- | --- |
| cron_enabled | true |
| task | "sync" |
| schedule | "0 */6 * * *" |

## Workloads
- main: container tty/stdin true; all probes disabled; service.main disabled (no ports)
- plextraktsync-cron: CronJob, schedule from values, restartPolicy Never, container `cron` (imageSelector image), args `["sync"]`, probes disabled

## Persistence
| Name | Mount |
| --- | --- |
| config | /app/config (main and cron) |

## Gotchas
- Chart runs as root (runAsUser 0). Entrypoint keeps root when PUID/PGID are unset or 0 (see `plextraktsync-entrypoint.md`).
