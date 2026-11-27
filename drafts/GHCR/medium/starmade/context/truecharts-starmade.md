# TrueCharts chart: starmade (stable)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/starmade/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `starmade` v11.0.0, library `common` 32.8.5, appVersion `latest`, category GameServers.
- Downloads and installs a StarMade dedicated server, installs a basic server.cfg on first start.

## Image (values.yaml)
- repository: `ghcr.io/ich777/starmade-server`
- tag: `latest@sha256:d80bb3b93a0e00d86b884f0e05ee778b9dc1dea43c79308a5b08735a47e17cd2`
- pullPolicy: IfNotPresent

## Ports
| name | port | proto |
| --- | --- | --- |
| main | 4242 | tcp |

## Persistence
| name | mountPath |
| --- | --- |
| serverfiles | /starmade |

## Env (set by chart)
| var | value |
| --- | --- |
| DATA_PERM | "770" |
| DL_URL | http://files.star-made.org/StarMade-Starter.jar |
| GAME_PARAMS | "" |
| RUNTIME_NAME | basicjre |
| STARTER_PARAMS | -nogui |
| XMS_SIZE | "1024" |
| XMX_SIZE | "1024" |

## Security context (chart defaults)
- readOnlyRootFilesystem: false, runAsUser: 0, runAsGroup: 0

## Other
- Chart sources: ghcr.io/ich777/starmade-server, www.star-made.org
- No probes or healthcheck overrides in values.
