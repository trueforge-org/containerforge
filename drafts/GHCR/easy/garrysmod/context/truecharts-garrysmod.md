# TrueCharts chart: garrysmod

Source URL(s):
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/garrysmod/values.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/garrysmod/Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `garrysmod` version 11.0.0, appVersion `garrysmod`, train stable.
- Description: installs SteamCMD, then installs Garry's Mod and runs it.
- Chart sources: `https://ghcr.io/ich777/steamcmd`, TrueCharts chart dir, https://www.steampowered.com/.

## Image
| Key | Value |
| --- | --- |
| repository | `ghcr.io/ich777/steamcmd` (GHCR) |
| tag | `garrysmod@sha256:8b7aa732d5317ea6ea3cd0c53d599af9121fd438fa6c4c536e48cc1f2cb4bfc7` |
| pullPolicy | IfNotPresent |

## Runtime env (workload.main.podSpec.containers.main.env)
| Name | Value |
| --- | --- |
| GAME_ID | "4020" |
| GAME_NAME | garrysmod |
| GAME_PARAMS | -secure +maxplayers 12 +map gm_flatgrass |
| GAME_PORT | "27015" |
| PASSWRD | secretKeyRef `env-secrets`/`PASSWRD` (empty default) |
| USERNAME | "" |
| VALIDATE | "false" |

## Ports
| Name | Port | Protocol | Target |
| --- | --- | --- | --- |
| main | 27015 | udp | 27015 |
| tcprcon | 27015 | tcp | 27015 |

## Volumes
| Persistence | mountPath |
| --- | --- |
| serverfiles | /serverdata/serverfiles |
| steamcmd | /serverdata/steamcmd |

## Security context
- readOnlyRootFilesystem: false, runAsUser 0, runAsGroup 0.

## Probes
- liveness, readiness, startup: `type: tcp` on 27015 (tcprcon).

## Gotchas
- `GAME_ID` 4020 is used by the chart as the server app ID. The Steam appdetails check for 4020 returned `success:false` (see README), so the chart value is the only source.
- `GAME_PARAMS` example values (`-secure +maxplayers 12 +map gm_flatgrass`) are chart defaults, not upstream defaults.
