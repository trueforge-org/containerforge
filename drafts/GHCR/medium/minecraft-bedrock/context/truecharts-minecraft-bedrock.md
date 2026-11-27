# TrueCharts minecraft-bedrock chart (stable)

Source URL(s) + date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/minecraft-bedrock/values.yaml (2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/minecraft-bedrock/Chart.yaml (2026-11-27)

## What it is
- Chart `minecraft-bedrock` version 16.0.0, appVersion 2026.11.1.
- Depends on `common` 32.8.5.

## Image
- repository: `ghcr.io/itzg/minecraft-bedrock-server`
- tag: `2026.11.1@sha256:463ea4ac99a3e5b67de0fc590a61cca7ea758520f67d9e4a4512fc3afcc97044`
- pullPolicy: Always

## Ports
| name | port | protocol |
| --- | --- | --- |
| main | 19132 | udp |

## Probes (chart, all exec, periodSeconds 60)
- liveness, readiness, startup: `/usr/local/bin/mc-monitor status-bedrock --host 127.0.0.1 --port 19132`

## Persistence
| name | mountPath |
| --- | --- |
| config | /data |

## Container flags
- tty: true, stdin: true.

## Env (chart values)
| var | value |
| --- | --- |
| EULA | true |
| ENABLE_LAN_VISIBILITY | true |
| VERSION | "LATEST" |
| SERVER_NAME | "TrueCharts Dedicated Server!" |
| SERVER_PORT | 19132 (templated from service) |
| GAMEMODE | survival |
| DIFFICULTY | easy |
| LEVEL_TYPE | DEFAULT |
| ALLOW_CHEATS | false |
| MAX_PLAYERS | 10 |
| ONLINE_MODE | true |
| WHITE_LIST | false |
| TRANSPORT | raknet |
| VIEW_DISTANCE | 32 |
| TICK_DISTANCE | 4 |
| PLAYER_IDLE_TIMEOUT | 30 |
| MAX_THREADS | 8 |
| LEVEL_NAME | "Bedrock level" |
| LEVEL_SEED | "" |
| DEFAULT_PLAYER_PERMISSION_LEVEL | member |
| TEXTUREPACK_REQUIRED | false |
| SERVER_AUTHORITATIVE_MOVEMENT | server-auth |
| PLAYER_MOVEMENT_SCORE_THRESHOLD | 20 |
| PLAYER_MOVEMENT_DISTANCE_THRESHOLD | 0.3 |
| PLAYER_MOVEMENT_DURATION_THRESHOLD_IN_MS | 500 |
| CORRECT_PLAYER_MOVEMENT | false |

Commented out in values: WHITE_LIST_USERS, OPS.

## Gotchas
- Chart VERSION=LATEST; the image's own version is pinned by digest.
