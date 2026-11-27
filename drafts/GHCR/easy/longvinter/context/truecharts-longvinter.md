# TrueCharts longvinter chart

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/longvinter/Chart.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/longvinter/values.yaml
- Fetched 2026-11-26

## What it is
TrueCharts Helm chart `longvinter` v11.0.0. Downloads SteamCMD and installs/runs Longvinter dedicated server. Category GameServers. Depends on `common` 32.8.5.

## Runtime deps
- Image: `ghcr.io/ich777/steamcmd`, tag `longvinter@sha256:893885f0b7db5577b9fea1e7c4dedd24d73cb24fb7d8d4105887b0dcaf8e612f`, pullPolicy IfNotPresent.

## Entrypoint/flags
- Not set in chart (image entrypoint used). GAME_PARAMS set to "" in chart.

## Env vars (chart values)
| Name | Value |
| --- | --- |
| GAME_PARAMS | "" |
| GAME_PORT | "27016" |

## Ports
- service.main `main`: 27016/udp.

## Volumes/paths
- persistence.serverfiles: `/serverdata/serverfiles` (enabled).
- persistence.steamcmd: `/serverdata/steamcmd` (enabled).

## User/UID
- runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.

## Healthcheck/probes
- liveness, readiness, startup disabled.

## Version/asset naming
- Chart 11.0.0. Image pinned by digest, tag prefix `longvinter`.

## Gotchas
- Chart.yaml `appVersion` is `longinter` (misspelled; not `longvinter`). Not a build input, but worth matching if plan references it.
