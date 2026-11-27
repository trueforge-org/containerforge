# TrueCharts chart: arma3 (fetched 2026-11-27)
Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/arma3/values.yaml , .../Chart.yaml

## What it is
- Chart `arma3` version 12.0.0, appVersion `arma3`, dep `common` 32.8.5
- Description: "This Chart will download and install SteamCMD. It will also install ArmA III and run it."
- Category GameServers; sources: https://ghcr.io/ich777/steamcmd , https://github.com/trueforge-org/truecharts/tree/master/charts/stable/arma3

## Image (values.yaml)
- repository `ghcr.io/ich777/steamcmd`
- tag `arma3@sha256:0823a8e9faa4b2d1db640c839ff3915388442d4b5f9cdd5227c1a60ee1fdf1bf`

## Security context
- readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0

## Persistence
| Name | mountPath |
| --- | --- |
| profiles | /serverdata/.local/share |
| serverfiles | /serverdata/serverfiles |
| steamcmd | /serverdata/steamcmd |

## Ports (service)
| Name | Port | Proto |
| --- | --- | --- |
| main | 2302 | tcp (targetPort 2302) |
| mainudp | 2302 | udp |
| udpbattleyetra | 2306 | udp |
| udpsteammaster | 2304 | udp |
| udpsteamquerry | 2303 | udp |
| udpvonport | 2305 | udp |

## Env (container `main`)
| Name | Chart value |
| --- | --- |
| GAME_ID | "233780" (Arma 3 dedicated server app id) |
| GAME_PARAMS | `-config=server.cfg -mod=` |
| GAME_PORT | "2302" |
| PASSWRD | secretKeyRef env-secrets/PASSWRD (default "") |
| USERNAME | "" |
| VALIDATE | "false" |

## Gotchas
- Chart uses env name `PASSWRD` (typo-like spelling kept); not `PASSWORD`
- Chart values set no probes
