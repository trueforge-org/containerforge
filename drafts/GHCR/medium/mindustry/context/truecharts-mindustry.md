# TrueCharts mindustry chart (stable)

Source URL(s) + date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/mindustry/values.yaml (2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/mindustry/Chart.yaml (2026-11-27)

## What it is
- Chart `mindustry` version 11.0.0, appVersion `latest`.
- Image: `ghcr.io/ich777/mindustry-server` (ich777 image, not built by TrueCharts).

## Image
- repository: `ghcr.io/ich777/mindustry-server`
- tag: `latest@sha256:89d872c76c01f14c108d5bfe09cc3407254c03ed15240532400acbc887d239bb`
- pullPolicy: IfNotPresent

## Ports
| name | port | protocol | targetPort |
| --- | --- | --- | --- |
| main | 6567 | tcp | 6567 |
| udpgameport | 6567 | udp | 6567 (enabled) |

## Persistence
| name | mountPath |
| --- | --- |
| serverfiles | /mindustry |

## Security
- securityContext: runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.

## Env (chart workload)
| var | value |
| --- | --- |
| GAME_PARAMS | "" |
| GAME_V | latest@sha256:f0065aa44fb1c38b7fc30d34e220138dc0a0c6477b78eb7f59015622c2052030 |
| SRV_NAME | DockerMindustry |

Gotcha: GAME_V in values is a digest-suffixed string, not a Mindustry version; the upstream start script compares it to a release tag (`latest` special-cased).
