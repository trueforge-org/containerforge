# TrueCharts chart: rss-bridge (stable)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/rss-bridge/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `rss-bridge` v17.0.0, appVersion `2025.6.3`, category media, depends on `common` 32.8.5.
- Description: PHP project generating RSS/Atom feeds for sites without one.
- Sources: https://ghcr.io/rss-bridge/rss-bridge , https://github.com/RSS-Bridge/rss-bridge

## Image
| Key | Value |
| --- | --- |
| repository | ghcr.io/rss-bridge/rss-bridge |
| tag | 2025-06-03@sha256:0eca99b2137425c3f73f237e8ed0af676b3085e9be8b76c033da14f0531a71d0 |
| pullPolicy | IfNotPresent |

## Ports
| Name | port |
| --- | --- |
| main | 10225 |

## Container env (chart override)
| Name | Value |
| --- | --- |
| HTTP_PORT | "{{ .Values.service.main.ports.main.port }}" (renders 10225) |

## Persistence
- `config`: enabled, mountPath `/config`
- `varrun`: disabled

## Security context (chart override)
- container: readOnlyRootFilesystem false, runAsNonRoot false, runAsUser 0, runAsGroup 0.
