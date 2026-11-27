# TrueCharts colonysurvival (stable chart v11.0.0, appVersion colonysurial)

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/colonysurvival/values.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/colonysurvival/Chart.yaml (fetched 2026-11-27)

## What it is
- "This Chart will download and install SteamCMD. It will also install Colony Survival and run it."
- Chart sources: ghcr.io/ich777/steamcmd, truecharts chart path, steampowered.com.
- Dependency: `common` 32.8.5.

## Image
- repository: `ghcr.io/ich777/steamcmd`
- tag: `colonysurvival@sha256:7e4f6d09caed6a1f566f599b0b3788f8805bc92f8ca9f4c6fade4d6bd3e3d566`
- pullPolicy: IfNotPresent

## Env vars (chart)
| Name | Chart value |
| --- | --- |
| GAME_ID | "748090" (Steam app ID) |
| GAME_PARAMS | `+server.gameport 27016` |
| PASSWRD | secretKeyRef env-secrets/PASSWRD (empty) |
| SRV_NAME | "Colony Survival Docker" |
| SRV_NETTYPE | SteamOnline |
| SRV_WORLDNAME | ColonySurvival |
| USERNAME | "" |
| VALIDATE | "false" |

## Ports
| Service | Port | Proto |
| --- | --- | --- |
| main | 27016 | udp |

Only one port; matches GAME_PARAMS gameport.

## Volumes/paths (persistence)
- `/serverdata/serverfiles`, `/serverdata/steamcmd`

## User/UID
- securityContext: runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.

## Healthcheck
- liveness, readiness, startup all disabled.

## Gotchas
- Chart appVersion string is "colonysurial" (typo upstream in chart).
- SRV_* env vars are chart-specific names; their use by the game is not verified from a fetched source.
