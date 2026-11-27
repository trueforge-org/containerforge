# TrueCharts xonotic (charts/stable/xonotic)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/xonotic/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `xonotic` v11.0.0, appVersion latest, train stable, depends on `common` 32.8.5.
- Sources: ghcr.io/ich777/xonotic, https://www.xonotic.org/.

## Image
- `ghcr.io/ich777/xonotic`, tag `latest@sha256:55c1f415...`.

## Ports
- service.main.ports.main: **26000 UDP** -> targetPort 26000.

## Env
| Var | Value |
| --- | --- |
| BASIC_URL | https://dl.xonotic.org/ |
| GAME_PARAMS | "" |
| GAME_VERSION | **0.8.2** (chart override; upstream Dockerfile default is 0.8.5) |

## Volumes
| Name | Mount |
| --- | --- |
| serverfiles | /serverdata/serverfiles |

## Security
- securityContext.container: readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0.

## Probes
- liveness, readiness, startup all `enabled: false`.
