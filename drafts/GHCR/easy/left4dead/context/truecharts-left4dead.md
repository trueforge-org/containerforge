# TrueCharts left4dead chart

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/left4dead/Chart.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/left4dead/values.yaml
- Fetched 2026-11-26

## What it is
TrueCharts Helm chart `left4dead` v11.0.0 (appVersion `l4d`). Downloads SteamCMD and installs/runs Left 4 Dead dedicated server. Category GameServers. Depends on `common` 32.8.5.

## Runtime deps
- Image: `ghcr.io/ich777/steamcmd`, tag `l4d@sha256:a4f89fc9a013ce1673949650645cc8b584227725d5b5526270d24eede7d856fc`, pullPolicy IfNotPresent.

## Entrypoint/flags
- Not set in chart (image entrypoint used).
- GAME_PARAMS: `+maxplayers 4 +map l4d_farm04_barn`.

## Env vars (chart values)
| Name | Value |
| --- | --- |
| GAME_ID | "222840" |
| GAME_NAME | left4dead |
| GAME_PARAMS | `+maxplayers 4 +map l4d_farm04_barn` |
| GAME_PORT | "27015" |
| USERNAME | "" |
| VALIDATE | "false" |
| PASSWRD | secretKeyRef env-secrets/PASSWRD (default "") |

## Ports
- service.main `main`: 27015/udp.
- service.tcprcon `tcprcon`: 27015/tcp (enabled, RCON).

## Volumes/paths
- persistence.serverfiles: `/serverdata/serverfiles` (enabled).
- persistence.steamcmd: `/serverdata/steamcmd` (enabled).

## User/UID
- runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.

## Healthcheck/probes
- liveness, readiness, startup: TCP probe on port `tcprcon` targetPort (27015).

## Version/asset naming
- Chart 11.0.0; image pinned by digest, tag prefix `l4d`.

## Gotchas
- Probes are TCP on 27015/tcp, which only works if the server exposes RCON on that port.
