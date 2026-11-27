# TrueCharts chart: static (stable)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/static/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `static` v16.0.0, library `common` 32.8.5, appVersion `ee8a20c`, category media.
- Self-hosted static file server: serves files from a mounted volume.

## Image (values.yaml)
- repository: `ghcr.io/nicholaswilde/static`
- tag: `version-ee8a20c@sha256:d1d47c730bc41c4ae46de8df0c9c76bb803927fcbe3446b6ff4f7cd152972940`
- pullPolicy: IfNotPresent

## Ports
| name | port (svc) | targetPort |
| --- | --- | --- |
| main | 10077 | 8000 |

## Persistence
| name | mountPath |
| --- | --- |
| data | /data |
| varrun | (default, enabled) |

## Env
- None set in values.

## Security context (chart values)
- readOnlyRootFilesystem: false, runAsNonRoot: false, runAsUser: 0, runAsGroup: 0

## Other
- Chart sources: ghcr.io/nicholaswilde/static, github.com/nicholaswilde/docker-static, github.com/prologic/static
