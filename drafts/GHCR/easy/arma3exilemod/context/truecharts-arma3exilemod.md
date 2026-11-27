# TrueCharts chart: arma3exilemod (fetched 2026-11-27)
Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/arma3exilemod/values.yaml , .../Chart.yaml

## What it is
- Chart `arma3exilemod` version 12.0.0, appVersion `arma3exilemod`, dep `common` 32.8.5
- Description: "This Chart will download and install SteamCMD. It will also install ArmA III including ExileMod and run it."
- Sources: https://ghcr.io/ich777/steamcmd only

## Image (values.yaml)
- repository `ghcr.io/ich777/steamcmd`
- tag `arma3exilemod@sha256:c664f8b47d669e3893f767f099c62792a070f295e52d7610dcd6a5391ea13994`

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
| tcpmariadb | 3306 | tcp |
| udpbattleyetra | 2306 | udp |
| udpsteammaster | 2304 | udp |
| udpsteamquerry | 2303 | udp |
| udpvonport | 2305 | udp |

## Env (container `main`)
| Name | Chart value |
| --- | --- |
| EXILEMOD_SERVER_URL | http://www.exilemod.com/ExileServer-1.0.4a.zip |
| GAME_ID | "233780" |
| GAME_PARAMS | "" |
| GAME_PORT | "2302" |
| MARIA_DB_ROOT_PWD | secretKeyRef env-secrets (placeholder "ExileMod") |
| PASSWRD | secretKeyRef env-secrets (default "") |
| USERNAME | "" |
| VALIDATE | "false" |
| WORKSHOP_MAN_INST | "" |

## Gotchas
- ExileMod zip URL is in the chart (EXILEMOD_SERVER_URL); the zip itself was not fetched (binary download, excluded)
- Chart exposes MariaDB port 3306 and a root password env
