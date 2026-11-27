# TrueCharts chart: fluidd

Source URL(s):
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/fluidd/values.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/fluidd/Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `fluidd` version 15.0.0, appVersion 1.38.1, train stable.
- Description: free and open-source Klipper web interface for 3D printers.
- Chart sources: `https://ghcr.io/fluidd-core/fluidd`, https://github.com/fluidd-core/fluidd.

## Image
| Key | Value |
| --- | --- |
| repository | `ghcr.io/fluidd-core/fluidd` (GHCR) |
| tag | `v1.38.1@sha256:09fde7bbec2d0016c2ad3270a715b632ddd0ef91d6898ed282ea0a9055aaec6c` |
| pullPolicy | IfNotPresent |

## Runtime
- securityContext: runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false.
- workload.main env: `{}` (none set).

## Ports
| Name | Port | targetPort | Protocol |
| --- | --- | --- | --- |
| main | 10224 | 80 | (default tcp) |

## Probes
- liveness, readiness, startup: `type: http`, `path: /`.

## Volumes
- None configured in the chart.

## Gotchas
- Chart runs as root; the image is nginx and serves static files on container port 80.
- Chart port 10224 maps to container 80 (upstream default `PORT=80`).
