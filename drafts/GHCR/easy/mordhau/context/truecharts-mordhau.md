# TrueCharts mordhau chart

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/mordhau/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/mordhau/Chart.yaml
- Fetched 2026-11-26

## What it is
TrueCharts Helm chart `mordhau` v11.0.0 (appVersion `mordhau`). Downloads SteamCMD and installs/runs the Mordhau dedicated server. Category GameServers. Depends on `common` 32.8.5. Chart description mentions initial server name `MordhauDocker`, server password `Chart`, admin password `adminChart`.

## Runtime deps
- Image: `ghcr.io/ich777/steamcmd`, tag `mordhau@sha256:fec246a17d24f63f17cdb4c1cdf6a6a2763afbaba7dbe5b4dec875de1c186384`, pullPolicy IfNotPresent.

## Entrypoint/flags
- Not set in chart (image entrypoint used). GAME_PARAMS "".

## Env vars (chart values)
| Name | Value |
| --- | --- |
| BEACON_PORT | "15000" |
| GAME_ID | "629800" |
| GAME_PARAMS | "" |
| GAME_PORT | "7777" |
| QUERY_PORT | "27015" |
| USERNAME | "" |
| VALIDATE | "false" |
| PASSWRD | secretKeyRef env-secrets/PASSWRD (default "") |

## Ports
- service.main `main`: 7777/udp (game).
- service.beaconport `beaconport`: 15000/udp (enabled).
- service.udp `udp`: 27015/udp (query, enabled).

## Volumes/paths
- persistence.serverfiles: `/serverdata/serverfiles` (enabled).
- persistence.steamcmd: `/serverdata/steamcmd` (enabled).

## User/UID
- runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.

## Healthcheck/probes
- liveness, readiness, startup disabled.

## Version/asset naming
- Chart 11.0.0. Image pinned by digest, tag prefix `mordhau`.

## Gotchas
- Chart description lists initial credentials (server/admin); these are defaults in text, not in values.
