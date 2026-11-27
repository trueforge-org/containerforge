# TrueCharts chart: fistfuloffrags

Source URL(s):
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/fistfuloffrags/values.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/fistfuloffrags/Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `fistfuloffrags` version 11.0.0, appVersion `fistfuloffrags`, train stable.
- Description: installs SteamCMD, then installs Fistful of Frags and runs it.
- Chart sources: `https://ghcr.io/ich777/steamcmd`, TrueCharts chart dir, https://www.steampowered.com/.

## Image
| Key | Value |
| --- | --- |
| repository | `ghcr.io/ich777/steamcmd` (GHCR) |
| tag | `fistfuloffrags@sha256:cafb0f50f66dbe187d05993f12ad5ee4284d2d5345aac03dff3a16014cec3699` |
| pullPolicy | IfNotPresent |

## Runtime env (workload.main.podSpec.containers.main.env)
| Name | Value |
| --- | --- |
| GAME_ID | "295230" |
| GAME_NAME | fof |
| GAME_PARAMS | +maxplayers 20 +map fof_fistful |
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
- liveness, readiness, startup: `type: tcp` on port 27015 (tcprcon targetPort). Chart uses TCP probes here.

## Gotchas
- `GAME_ID` 295230 is the dedicated server app ID the chart uses. Steam appdetails for 295230 returned `success:false`. The chart value is the only source.
- Client app 265630 is the store app (type game, platforms windows/mac/linux).
- Chart uses the same port 27015 for udp and tcp.
