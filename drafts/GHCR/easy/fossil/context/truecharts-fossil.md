# TrueCharts chart: fossil

Source URL(s):
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/fossil/values.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/fossil/Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `fossil` version 17.0.0, appVersion 2.15.1, train stable.
- Description: simple, high-reliability, distributed software configuration management system.
- Chart sources: https://fossil-scm.org/, `https://ghcr.io/nicholaswilde/fossil`, TrueCharts chart dir.

## Image
| Key | Value |
| --- | --- |
| repository | `ghcr.io/nicholaswilde/fossil` (GHCR, community image, not Docker Hub) |
| tag | `2.15.1-ls4@sha256:a0a819ed2707e8e829dec371de0e166fbcf0499d3d12005880f603b2b95bf64d` |
| pullPolicy | IfNotPresent |

## Runtime
- securityContext: runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false.
- workload.main env: `{}`.

## Ports
| Name | Port | targetPort |
| --- | --- | --- |
| main | 10083 | 8080 |

## Volumes
| Persistence | mountPath |
| --- | --- |
| varrun (enabled) | not set in the chart (chart default path) |

## Probes
- liveness, readiness, startup: `type: http`, `path: /`.

## Gotchas
- Chart port 10083 maps to container port 8080.
- The chart image is the community Alpine build (2.15.1, ls4 tag). The plan replaces it with an Ubuntu apt build.
