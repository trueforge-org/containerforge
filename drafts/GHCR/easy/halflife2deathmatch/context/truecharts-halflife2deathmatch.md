# TrueCharts halflife2deathmatch (stable)

## Source URL(s) + date

- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/halflife2deathmatch/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/halflife2deathmatch/Chart.yaml
- Fetched 2026-11-27

## What it is

- Chart `halflife2deathmatch` v11.0.0, appVersion `hl2dm`. Installs SteamCMD and runs HL2:DM dedicated server.
- Category: GameServers. Depends on `common`.
- Chart sources: ghcr.io/ich777/steamcmd, steampowered.com.

## Image

| Key | Value |
| --- | --- |
| repository | `ghcr.io/ich777/steamcmd` |
| tag | `hl2dm@sha256:90734cad0bfa1f79dafdec123386f883f9df23d760f860544fd6a4272c62e7bf` |
| pullPolicy | IfNotPresent |

- GHCR only (no Docker Hub image referenced).

## Game settings (chart env)

| Var | Value | Notes |
| --- | --- | --- |
| GAME_ID | `232370` | Steam app ID as set by chart. Lead for plan.md blocker (see README); not independently verified here |
| GAME_NAME | `hl2mp` | srcds `-game` value |
| GAME_PARAMS | `-secure +maxplayers 16 +map dm_overwatch` | |
| GAME_PORT | `"27015"` | |
| USERNAME | `""` | anonymous |
| VALIDATE | `"false"` | |
| PASSWRD | secretKeyRef `env-secrets`/`PASSWRD` | empty in chart |

## Ports

| Name | Port | Protocol | Notes |
| --- | --- | --- | --- |
| main | 27015 | udp | game |
| tcprcon | 27015 | tcp | enabled; rcon |

## Volumes / paths

| Name | Mount |
| --- | --- |
| serverfiles | `/serverdata/serverfiles` |
| steamcmd | `/serverdata/steamcmd` |

## User / UID

- `securityContext.container`: `runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`.

## Probes

- liveness, readiness, startup: `type: tcp` on port 27015 (tcprcon).

## Gotchas

- Chart probes use TCP on 27015 (rcon) while game is UDP on 27015.
