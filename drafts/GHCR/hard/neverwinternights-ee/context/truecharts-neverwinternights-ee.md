# TrueCharts chart: neverwinternights-ee

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/neverwinternights-ee/{Chart.yaml,values.yaml} (fetched 2026-11-27)

## What it is
- Chart `neverwinternights-ee` v11.0.0, appVersion `latest`, category GameServers.
- Description: installs Neverwinter Nights: Enhanced Edition and runs it; default chart has MariaDB and Redis integrated.
- Sources/annotations: see Chart.yaml (not extracted beyond category/version/description).

## Image
- repository: `ghcr.io/ich777/nwnee-server`
- tag: `latest@sha256:6adc2ce5537e2cea0b575d2b8e8f3a9921bc38dd74a9458c7ffc2ba2093b7513`
- pullPolicy: IfNotPresent

## Service / ports
- service.main port 5121, protocol **udp**, targetPort 5121.

## Persistence
| Name | mountPath |
| --- | --- |
| serverfiles | /nwnee |

## Env (container main)
| Env | Chart value | Image default (ich777 Dockerfile) |
| --- | --- | --- |
| APWD | adminDocker | adminDocker |
| PPW | Docker | Docker |
| SRV_NAME | Docker NWNEE | Docker NWN:EE |
| MAX_CLIENTS | 4 | 4 |
| MINLEVEL | 1 | 1 |
| MAXLEVEL | 40 | 40 |
| PVP | 0 | 0 |
| PAUSEAPLAY | 0 | 0 |
| SERVERVAULT | 0 | 0 |
| ELC | 0 | 0 |
| ILR | 0 | 0 |
| ONEPARTY | 0 | 0 |
| DIFF | 1 | 1 |
| AUTO_SAV_I | 5 | 5 |
| PUBLIC_SRV | 0 | 0 |
| RLD_W_E | 0 | 1 (image) |
| LOG_LVL | 4 | 6 (image) |
| MOD_NAME | "" | "" |
| GAME_PARAMS | "" | "" |

## Probes
- liveness, readiness, startup all disabled (enabled: false).

## Security
- readOnlyRootFilesystem false; runAsUser 0; runAsGroup 0.

## Gotchas
- Chart image is `ghcr.io/ich777/nwnee-server`, not the ich777/docker-nwnee repo image name; the Dockerfile in that repo is the build source.
- Probes disabled; UDP service only.
