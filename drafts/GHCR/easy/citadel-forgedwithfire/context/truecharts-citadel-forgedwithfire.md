# TrueCharts citadel-forgedwithfire (stable chart v11.0.0, appVersion citadelfwf)

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/citadel-forgedwithfire/values.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/citadel-forgedwithfire/Chart.yaml (fetched 2026-11-27)

## What it is
- "This Chart will download and install SteamCMD. It will also install Citadel - Forged with Fire and run it."
- Chart sources: ghcr.io/ich777/steamcmd, truecharts chart path, steampowered.com.
- Dependency: `common` 32.8.5.

## Image
- repository: `ghcr.io/ich777/steamcmd`
- tag: `citadelfwf@sha256:bcf40be84f6d98cb12a200e838ca01beb7dbd13842d6716c62673b8e1d12eb8d`
- pullPolicy: IfNotPresent

## Env vars (chart)
| Name | Chart value |
| --- | --- |
| GAME_ID | `"489650 "` (trailing space in chart value) |
| GAME_PARAMS | "" |
| PASSWRD | secretKeyRef env-secrets/PASSWRD (empty) |
| USERNAME | "" (anonymous) |
| VALIDATE | "false" |

## Ports
| Service | Port | Proto |
| --- | --- | --- |
| main | 7777 | udp |
| queryport | 27015 | udp (enabled) |

## Volumes/paths (persistence)
- `/serverdata/serverfiles`, `/serverdata/steamcmd`

## User/UID
- securityContext: runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.

## Healthcheck
- liveness, readiness, startup all disabled.

## Gotchas
- GAME_ID has a trailing space; trim before use.
- Both ports are UDP.
