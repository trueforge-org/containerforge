# TrueCharts insurgencysandstorm (stable)

## Source URL(s) + date

- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/insurgencysandstorm/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/insurgencysandstorm/Chart.yaml
- Fetched 2026-11-27

## What it is

- Chart `insurgencysandstorm` v11.0.0, appVersion `insurgencysandstorm`. Installs SteamCMD and runs Insurgency: Sandstorm dedicated server.
- Category: GameServers. Depends on `common`.
- Chart sources: ghcr.io/ich777/steamcmd, steampowered.com.

## Image

| Key | Value |
| --- | --- |
| repository | `ghcr.io/ich777/steamcmd` |
| tag | `insurgencysandstorm@sha256:755cb75b05690879a7dea1f6945b44cf62edea61ef5d90106fb209e1b2bebbd2` |
| pullPolicy | IfNotPresent |

- GHCR only (no Docker Hub image referenced).

## Game settings (chart env)

| Var | Value | Notes |
| --- | --- | --- |
| GAME_ID | `581330` | Steam dedicated server app ID (per chart) |
| GAME_PARAMS | `Oilfield?Scenario=Scenario_Refinery_Push_Security?MaxPlayers=28?Password=Docker` | chart default; `Password=Docker` is a placeholder |
| GAME_PORT | `"27102"` | |
| QUERY_PORT | `"27131"` | |
| SERVER_NAME | `DockerServer` | |
| USERNAME | `""` | anonymous |
| VALIDATE | `"false"` | |
| PASSWRD | secretKeyRef `env-secrets`/`PASSWRD` | empty in chart |

## Ports

| Name | Port | Protocol |
| --- | --- | --- |
| main | 27102 | udp (game) |
| queryport | 27131 | udp (enabled) |

## Volumes / paths

| Name | Mount |
| --- | --- |
| serverfiles | `/serverdata/serverfiles` |
| steamcmd | `/serverdata/steamcmd` |

## User / UID

- `securityContext.container`: `runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`.

## Probes

- liveness, readiness, startup: all disabled.

## Gotchas

- Ports are UDP: no TCP probe possible.
- Do not ship the chart's `Password=Docker` placeholder as a default.
