# TrueCharts minecraft-java chart (stable)

Source URL(s) + date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/minecraft-java/values.yaml (2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/minecraft-java/Chart.yaml (2026-11-27)

## What it is
- Chart `minecraft-java` version 37.0.0, appVersion 2026.11.1, depends on `common` 32.8.5.

## Images (all ghcr.io/itzg/minecraft-server, pullPolicy Always)
| value key | tag |
| --- | --- |
| image (default) | 2026.11.1-java25 |
| j25jdkImage | 2026.11.1-java25-jdk |
| j21Image | 2026.11.1-java21 |
| j21alpineImage | 2026.11.1-java21-alpine |
| j21jdkImage | 2026.11.1-java21-jdk |
| j17Image | 2026.11.1-java17 |
| j17jdkImage | 2024.6.1-java17-jdk (older tag) |
| j16Image | 2026.11.1-java16 |
| j11Image | 2026.11.1-java11 |
| j8Image | 2026.11.1-java8 |

Each has a pinned sha256 digest in values.yaml. Default `image` tag is `2026.11.1-java25@sha256:0634ff76...`.
Workload uses `imageSelector: image`.

## Ports
| service | protocol | port | targetPort |
| --- | --- | --- | --- |
| main | tcp | 25565 | - |
| query | udp | 25565 | - |
| rcon | tcp | 25575 | - |
| ssh | tcp | 2222 | 2222 (enabled) |

## Probes
- liveness, readiness, startup: exec `mc-health`.

## Persistence
| name | mountPath |
| --- | --- |
| data | /data |

## Env (chart workload)
| var | value |
| --- | --- |
| SERVER_PORT | 25565 (templated) |
| QUERY_PORT | 25565 (templated) |
| RCON_PORT | 25575 (templated) |
| ENABLE_QUERY | "true" |
| ENABLE_SSH | "false" |
| EULA | "TRUE" |
| GUI | "FALSE" |
| OVERRIDE_SERVER_PROPERTIES | true |
| VERSION | "LATEST" |
| TYPE | "VANILLA" |
| DIFFICULTY | easy |
| MAX_PLAYERS | 20 |
| MAX_WORLD_SIZE | 10000 |
| ALLOW_NETHER | true |
| ANNOUNCE_PLAYER_ACHIEVEMENTS | true |
| ENABLE_COMMAND_BLOCK | false |
| FORCE_GAMEMODE | false |
| GENERATE_STRUCTURES | true |
| HARDCORE | false |
| MAX_BUILD_HEIGHT | 256 |
| MAX_TICK_TIME | 60000 |
| SPAWN_ANIMALS / SPAWN_MONSTERS / SPAWN_NPCS | true |
| VIEW_DISTANCE | 16 |
| MODE | survival |
| MOTD | "Welcome to Minecraft on TrueNAS Scale!" |
| PVP | false |
| LEVEL_TYPE | DEFAULT |
| LEVEL | world |
| ONLINE_MODE | true |
| MEMORY | 2048M |
| RCON_PASSWORD | secretKeyRef env-secrets/RCON_PASSWORD |

Secret `env-secrets` (chart) holds placeholder `RCON_PASSWORD: "secretrconpass"`; must be changed.
Many options are commented out (TYPE-specific downloads, OPS, WHITELIST, ICON, etc.).

## Gotchas
- j17jdkImage tag is `2024.6.1-java17-jdk`, not 2026.11.1 like the other entries.
