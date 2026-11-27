# TrueCharts pvk-ii chart

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/pvk-ii/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/pvk-ii/Chart.yaml
- Fetched 2026-11-27

## What it is
- "This Chart will download and install SteamCMD. It will also install Pirates, Vikings & Knights 2 and run it." Chart 11.0.0, appVersion `pkii` (non-numeric), GameServers
- Dependency: `common` 32.8.5 (oci://oci.trueforge.org/truecharts)
- Chart sources: ghcr.io/ich777/steamcmd, Steam homepage

## Image (values.yaml)
- repository: `ghcr.io/ich777/steamcmd` (GHCR, no Docker Hub source)
- tag: `pvkii@sha256:22d30823848fc33bd937257181430c4bf263ee9c7edbf2704a7f044b6df918f5`

## Env (workload.main container)
| Name | Value |
| --- | --- |
| DATA_PERM | "770" |
| GAME_ID | "17575" |
| GAME_NAME | pvkii |
| GAME_PARAMS | -maxplayers 18 +map bt_island |
| GAME_PORT | "27015" |
| PASSWRD | secretKeyRef env-secrets/PASSWRD |
| USERNAME | "" |
| VALIDATE | "false" |

## Secrets
- secret `env-secrets`: PASSWRD ''

## Ports (service)
| Service | Port | Proto |
| --- | --- | --- |
| main | 27015 | udp |
| tcprcon | 27015 | tcp (enabled) |

## Probes
- liveness, readiness, startup: TCP on tcprcon port 27015

## Persistence
| Name | Mount |
| --- | --- |
| serverfiles | /serverdata/serverfiles |
| steamcmd | /serverdata/steamcmd |

## Security
- runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false

## Gotchas
- GAME_NAME `pvkii` is used as the srcds `-game` value by the ich777 start script (see `ich777-docker-steamcmd-server.md`). The ich777 script hard-wires `srcds_run`; whether PVK-II uses it was not verified.
