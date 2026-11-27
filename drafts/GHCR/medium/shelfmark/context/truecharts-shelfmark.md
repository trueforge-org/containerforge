# TrueCharts chart: shelfmark (stable)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/shelfmark/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `shelfmark` v3.0.2, appVersion `1.7.2`, category media, depends on `common` 32.8.5.
- Description: self-hosted Calibre companion for searching, organising and downloading ebooks.
- Sources: https://ghcr.io/calibrain/shelfmark , https://github.com/calibrain/shelfmark

## Image
| Key | Value |
| --- | --- |
| repository | ghcr.io/calibrain/shelfmark |
| tag | v1.7.2@sha256:c7d2e085e1828334653bee22fbcb2a8728bb2e2503a5c7d72601966c79510629 |
| pullPolicy | IfNotPresent |

Note: chart pins v1.7.2 (not v1.7.0).

## Ports
| Name | port | targetPort | protocol |
| --- | --- | --- | --- |
| main | 8084 | 8084 | http |

## Persistence
- `config`: enabled, mountPath `/config`

## Container env (chart override)
| Name | Value |
| --- | --- |
| LOG_ROOT | /var/logs |

## Probes
- liveness, readiness, startup: type http, path `/api/health`.
