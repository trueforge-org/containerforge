# TrueCharts memories-of-mars chart

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/memories-of-mars/Chart.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/memories-of-mars/values.yaml
- Fetched 2026-11-26

## What it is
TrueCharts Helm chart `memories-of-mars` v11.0.0 (appVersion `memoriesofmars`). Downloads SteamCMD and installs/runs Memories of Mars dedicated server. Category GameServers. Depends on `common` 32.8.5.

## Runtime deps
- Image: `ghcr.io/ich777/steamcmd`, tag `memoriesofmars@sha256:249ded0bb7506f842c9b8f2eff974bee43aa71087f6dd63ea5cdc129089804b8`, pullPolicy IfNotPresent.

## Entrypoint/flags
- Not set in chart (image entrypoint used).

## Env vars (chart values)
| Name | Value |
| --- | --- |
| GAME_ID | "897590" |
| GAME_PARAMS | "" |
| MULTIHOME | "" |
| USERNAME | "" |
| VALIDATE | "false" |
| PASSWRD | secretKeyRef env-secrets/PASSWRD (default "") |

## Ports
- service.main `main`: 7777/udp.
- service.beaconport `beaconport`: 15000/udp (enabled).

## Volumes/paths
- persistence.serverfiles: `/serverdata/serverfiles` (enabled).
- persistence.steamcmd: `/serverdata/steamcmd` (enabled).

## User/UID
- runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.

## Healthcheck/probes
- liveness, readiness, startup disabled.

## Version/asset naming
- Chart 11.0.0. Image pinned by digest, tag prefix `memoriesofmars`.

## Gotchas
- Chart exposes `MULTIHOME` env (not in ich777 master Dockerfile defaults; the game-specific branch was not fetched).
