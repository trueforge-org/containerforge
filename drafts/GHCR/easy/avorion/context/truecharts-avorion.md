# TrueCharts avorion (stable chart v12.0.0)

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/avorion/values.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/avorion/Chart.yaml (fetched 2026-11-27)

## What it is
- Chart description: installs SteamCMD and Avorion, then runs the server.
- Chart `appVersion: aorion` (sic, typo in upstream chart).
- Chart sources: ghcr.io/ich777/steamcmd, truecharts chart path, steampowered.com.
- Dependency: `common` 32.8.5 from oci://oci.trueforge.org/truecharts.

## Image
- repository: `ghcr.io/ich777/steamcmd`
- tag: `avorion@sha256:70a10bfbddc1554102f7b5b99673521fcb8a5f4a8593b58686a04629457e5873` (pinned digest, tag name `avorion`)
- pullPolicy: IfNotPresent

## Env vars
| Name | Chart default | Notes |
| --- | --- | --- |
| GALAXY_NAME | AvorionDocker | galaxy name |
| GAME_ID | "565060" | Steam app ID (Avorion) |
| GAME_PARAMS | "" | extra server params |
| PASSWRD | secretKeyRef env-secrets/PASSWRD | server password (secret) |
| USERNAME | "" | Steam login (empty = anonymous) |
| VALIDATE | "false" | SteamCMD validate flag |

## Ports
| Service | Port | Proto |
| --- | --- | --- |
| main | 27000 | tcp |
| mainudp | 27000 | udp |
| hostport3 | 27003 | udp |
| hostport4 | 27020 | udp |
| hostport5 | 27021 | udp |

## Volumes/paths
- `/serverdata/serverfiles` (persistence serverfiles)
- `/serverdata/steamcmd` (persistence steamcmd)

## User/UID
- securityContext: runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.

## Config files
- none in chart values beyond env.

## Healthcheck
- liveness, readiness, startup probes all disabled in chart.

## Gotchas
- stdin and tty set to true in chart.
- Chart secret `env-secrets` with key PASSWRD (empty default).
