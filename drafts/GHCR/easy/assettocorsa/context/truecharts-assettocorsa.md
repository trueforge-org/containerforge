# TrueCharts chart: assettocorsa (fetched 2026-11-27)
Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/assettocorsa/values.yaml , .../Chart.yaml

## What it is
- Chart `assettocorsa` version 12.0.0, appVersion `assettocorsa`, dep `common` 32.8.5
- Description: "This Chart will download and install SteamCMD. It will also install AssettoCorsa and run it."
- Sources: https://ghcr.io/ich777/steamcmd , https://www.assettocorsa.net/

## Image (values.yaml)
- repository `ghcr.io/ich777/steamcmd`
- tag `assettocorsa@sha256:ae225d6d3b2e777f8be99ac3bb6c3eace7057aef8d78abbeb8b3407e51b87acf`

## Security context
- readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0

## Persistence
| Name | mountPath |
| --- | --- |
| serverfiles | /serverdata/serverfiles |
| steamcmd | /serverdata/steamcmd |

## Ports (service)
| Name | Port | Proto |
| --- | --- | --- |
| main | 9600 | tcp |
| mainudp | 9600 | udp |
| assetto | 8772 | tcp |
| stracker | 50041 | tcp |
| tcp2 | 8081 | tcp |

## Env (container `main`)
| Name | Chart value |
| --- | --- |
| GAME_ID | "302550" (Steam app id, Assetto Corsa dedicated server) |
| INSTALL_ASSETTO_SERVER_MANAGER | "" |
| INSTALL_STRACKER | "" |
| PASSWRD | secretKeyRef env-secrets (default "") |
| USERNAME | "" |
| VALIDATE | "false" |

## Gotchas
- Chart has no profiles persistence (only serverfiles and steamcmd)
- Optional installers exist as env flags (ASSETTO_SERVER_MANAGER, STRACKER), empty by default
