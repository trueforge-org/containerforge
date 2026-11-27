# TrueCharts postscriptum chart

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/postscriptum/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/postscriptum/Chart.yaml
- Fetched 2026-11-27

## What it is
- "This Chart will download and install SteamCMD. It will also install PostScriptum and run it." Chart 11.0.0, appVersion `postscriptum` (non-numeric), GameServers
- Dependency: `common` 32.8.5 (oci://oci.trueforge.org/truecharts)
- Chart sources: ghcr.io/ich777/steamcmd, Steam homepage

## Image (values.yaml)
- repository: `ghcr.io/ich777/steamcmd` (GHCR, no Docker Hub source)
- tag: `postscriptum@sha256:abb80492503ad11433b75da07817772d293c91eacc8f44565d1719d273131f3e`
- pullPolicy: IfNotPresent

## Env (workload.main container)
| Name | Value |
| --- | --- |
| DATA_PERM | "770" |
| GAME_ID | "746200" |
| GAME_PARAMS | "Port=10027 QueryPort=10037 -log" |
| PASSWRD | secretKeyRef env-secrets/PASSWRD |
| USERNAME | "" |
| VALIDATE | "false" |

## Secrets
- secret `env-secrets` (enabled): PASSWRD ""

## Ports (service)
| Service | Port | Proto | Target |
| --- | --- | --- | --- |
| main | 10027 | udp | 10027 |
| queryport | 10037 | udp | 10037 (enabled) |

## Persistence
| Name | Mount |
| --- | --- |
| serverfiles | /serverdata/serverfiles |
| steamcmd | /serverdata/steamcmd |

## Security / probes
- runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false
- probes liveness/readiness/startup disabled

## Gotchas
- GAME_PARAMS passes game-specific args (Port, QueryPort). How they reach the launch command depends on the ich777 start scripts (see `ich777-docker-steamcmd-server.md`; that file documents `srcds_run -game ${GAME_NAME} ${GAME_PARAMS} -console +port ${GAME_PORT}`, unverified for this game).
