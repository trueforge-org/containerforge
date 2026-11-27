# TrueCharts hurtworld (stable)

## Source URL(s) + date

- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/hurtworld/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/hurtworld/Chart.yaml
- Fetched 2026-11-27

## What it is

- Chart `hurtworld` v11.0.0, appVersion `hurtworld`. Installs SteamCMD and runs Hurtworld dedicated server.
- Category: GameServers. Depends on `common`.
- Chart sources: ghcr.io/ich777/steamcmd, steampowered.com.

## Image

| Key | Value |
| --- | --- |
| repository | `ghcr.io/ich777/steamcmd` |
| tag | `hurtworld@sha256:c12cb82fa4a2e2e4a214241428469a88bb52993634f2a3a2097259c63d1acac9` |
| pullPolicy | IfNotPresent |

- GHCR only (no Docker Hub image referenced).

## Game settings (chart env)

| Var | Value | Notes |
| --- | --- | --- |
| GAME_ID | `405100` | Steam app ID (dedicated server, per chart) |
| GAME_PARAMS | `;autosaveenabled 1;addadmin 76561197963117432` | chart default; contains an admin SteamID |
| GAME_PORT | `"12871"` | |
| QUERY_PORT | `"12881"` | |
| SRV_NAME | `Hurtworld Docker` | |
| SRV_MAXPLAYERS | `"50"` | |
| USERNAME | `""` | anonymous |
| VALIDATE | `"false"` | |
| PASSWRD | secretKeyRef `env-secrets`/`PASSWRD` | empty in chart |

## Ports

| Name | Port | Protocol |
| --- | --- | --- |
| main | 12871 | udp (game) |
| queryport | 12881 | udp (enabled) |

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
- Chart GAME_PARAMS includes an admin SteamID default (not recorded as a requirement).
