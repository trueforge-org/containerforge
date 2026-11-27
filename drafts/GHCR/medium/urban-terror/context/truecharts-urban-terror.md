# TrueCharts urban-terror (charts/stable/urban-terror)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/urban-terror/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `urban-terror` v11.0.0, appVersion latest, train stable, depends on `common` 32.8.5.
- Sources: ghcr.io/ich777/urbanterror, https://www.urbanterror.info/.

## Image
- `ghcr.io/ich777/urbanterror`, tag `latest@sha256:a1c4a9d0...`.

## Ports
- service.main.ports.main: **27960 UDP** -> targetPort 27960.

## Env
| Var | Value |
| --- | --- |
| CHECK_FOR_UPDATES | "true" |
| START_PARAMS | "" |

## Volumes
| Name | Mount |
| --- | --- |
| datadir | /urbanterror |

## Security
- securityContext.container: readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0.

## Probes
- liveness, readiness, startup all `enabled: false`.
