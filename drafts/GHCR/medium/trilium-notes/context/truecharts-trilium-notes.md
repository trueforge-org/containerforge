# TrueCharts chart: trilium-notes (stable)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/trilium-notes/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `trilium-notes` v18.0.0, library `common` 32.8.5, appVersion 0.63.7, category media.
- Hierarchical note-taking app for personal knowledge bases.

## Image (values.yaml)
- repository: `ghcr.io/zadam/trilium`
- tag: `0.63.7@sha256:a0b5a6a5fd7a64391ae6039bbcd5493151a77a1d5470ef5911923c64d0c232c0`
- pullPolicy: IfNotPresent

## Ports
| name | port (svc) | targetPort | proto |
| --- | --- | --- | --- |
| main | 10156 | 8080 | http |

## Persistence
| name | mountPath |
| --- | --- |
| config | /home/node |

## Env
- None set in values (chart uses defaults).

## Security context (chart values)
- container: runAsNonRoot false, runAsUser 0, runAsGroup 0.
- pod: fsGroup 1000.

## Other
- Chart sources: ghcr.io/zadam/trilium, github.com/zadam/trilium.
