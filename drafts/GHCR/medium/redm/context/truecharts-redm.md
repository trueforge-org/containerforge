# TrueCharts chart: redm (stable)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/redm/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `redm` v12.0.0, appVersion `latest`, category GameServers, depends on `common` 32.8.5.
- RedM (Red Dead Redemption 2 mod server). Chart downloads the latest FXServer build (or user sets MANUAL_UPDATES), extracts it, and fetches resources and server.cfg. Requires a valid FiveM Server Key (https://keymaster.fivem.net/) and a server name.
- Sources: https://ghcr.io/ich777/redmserver , https://redm.gg/

## Image
| Key | Value |
| --- | --- |
| repository | ghcr.io/ich777/redmserver |
| tag | latest@sha256:40114bd20d141ec86e51b9d9cd2f904c97579aa5be4d00a1bfee6c95622b3d43 |
| pullPolicy | IfNotPresent |

## Ports
| Name | port | targetPort | protocol |
| --- | --- | --- | --- |
| main | 9016 | 8080 | http |
| port1tcp | 30110 | 30110 | tcp |
| port2tcp | 30120 | 30120 | tcp |
| port1udp | 30110 | 30110 | udp |
| port2udp | 30120 | 30120 | udp |

## Persistence
- `serverfiles`: enabled, mountPath `/serverdata/serverfiles`

## Container env (chart override)
| Name | Value |
| --- | --- |
| GAME_CONFIG | server.cfg |
| MANUAL_UPDATES | "" |
| SERVER_KEY | secretKeyRef env-secrets/SERVER_KEY |
| SRV_ADR | https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/ |
| SRV_NAME | "" |
| START_VARS | "" |

Secret `env-secrets` (enabled) with key `SERVER_KEY: ""`.

## Probes
- Not set in values.yaml.

## Security context (chart override)
- container: readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0.
