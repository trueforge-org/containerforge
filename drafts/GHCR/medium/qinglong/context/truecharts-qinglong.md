# TrueCharts chart: qinglong (stable)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/qinglong/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `qinglong` v15.0.0, appVersion 2.24.0, type application, depends on `common` 32.8.5 (oci.trueforge.org/truecharts).
- Description: timed task management panel (TypeScript, JavaScript, Python3, shell).
- Sources: https://ghcr.io/whyour/qinglong

## Image
| Key | Value |
| --- | --- |
| repository | ghcr.io/whyour/qinglong |
| tag | 2.24.0@sha256:2431b8b92d5822423d7d598110294691ae2a32d7fbde5c5d5a963db8b4f47cc3 |
| pullPolicy | IfNotPresent |

## Ports
| Name | targetPort | service port |
| --- | --- | --- |
| main | 5700 | 10176 |

## Persistence
- `data`: enabled, mountPath `/ql/data`

## Security context (chart override)
- container: readOnlyRootFilesystem false, runAsNonRoot false, runAsUser 0, runAsGroup 0

## Not present in chart
- No env, probes, or secrets defined in values.yaml.
