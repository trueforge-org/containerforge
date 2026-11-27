# TrueCharts counterstrike2d chart

Source URL(s) + date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/counterstrike2d/Chart.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/counterstrike2d/values.yaml
- Fetched 2026-11-27

## What it is
- Chart `counterstrike2d` v11.0.0, appVersion `latest`, type application.
- Description: installs CounterStrike 2D.
- Depends on `common` 32.8.5 (oci://oci.trueforge.org/truecharts).
- kubeVersion `>=1.33.0-0`; min helm 3.14; max helm 4.1; max k8s 1.35.0.
- Chart sources list: `ghcr.io/ich777/cs2dserver`, Steam page.

## Image (values.yaml)
| Key | Value |
| --- | --- |
| repository | `ghcr.io/ich777/cs2dserver` |
| tag | `latest@sha256:704e5c805d0c64d6c1ceb98103aa3b67b3a5ebb6f6a085eabd9c63778e81d9cd` |
| pullPolicy | IfNotPresent |

## Env (workload.main.podSpec.containers.main.env)
| Name | Value |
| --- | --- |
| FORCE_UPDATE | `""` |
| GAME_PARAMS | `""` |

## Persistence
| Name | Mount path |
| --- | --- |
| serverfiles | `/serverdata/serverfiles` |

## Ports
- Service `main`, port `main`: `port: 36963`, `targetPort: 36963`, `protocol: udp` (UDP only; no tcp entry).

## Security context
- runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.

## Probes
- liveness, readiness, startup all disabled.

## Gotchas
- Chart runs as root with writable rootfs (not read-only compatible as shipped).
- Image pinned by digest with `latest` tag.
- Chart port is UDP 36963 only.
