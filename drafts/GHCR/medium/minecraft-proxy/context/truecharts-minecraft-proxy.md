# TrueCharts minecraft-proxy chart (stable)

Source URL(s) + date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/minecraft-proxy/values.yaml (2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/minecraft-proxy/Chart.yaml (2026-11-27)

## What it is
- Chart `minecraft-proxy` version 9.0.0, appVersion 2026.11.2.
- Image family `ghcr.io/itzg/mc-proxy` (BungeeCord/Velocity proxy image). Depends on `common` 32.8.5 (per chart).

## Images (pullPolicy Always, all digest-pinned)
| key | tag |
| --- | --- |
| image | 2026.11.2-java21 |
| j8Image | 2026.11.2-java8 |
| j17Image | 2026.11.2-java17 |
| j25Image | 2026.11.2-java25 |

workload `imageSelector: image`.

## Ports
| service | port | targetPort |
| --- | --- | --- |
| main | 25565 | 25577 |
| rcon | 25578 (enabled) | - |

## Probes
- liveness, readiness, startup: `type: tcp`.

## Persistence
| name | mountPath |
| --- | --- |
| config | /config |
| server | /server |
| plugins | /plugins |

## Env (chart workload)
| var | value |
| --- | --- |
| RCON_PORT | 25578 (templated) |
| RCON_PASSWORD | secretKeyRef env-secrets/RCON_PASSWORD (placeholder "secretrconpass") |
| TYPE | "BUNGEECORD" |
| ONLINE_MODE | false |
| MEMORY / INIT_MEMORY / MAX_MEMORY | 512M |
| NETWORKADDRESS_CACHE_TTL | 60 |
| REPLACE_ENV_VARIABLES | false |
| ENV_VARIABLE_PREFIX | "CFG_" |

Commented out: GENERIC_PACKS, GENERIC_PACKS_PREFIX, GENERIC_PACKS_SUFFIX, JVM_OPTS, JVM_XX_OPTS, PLUGINS.

## Gotchas
- Chart default TYPE is BUNGEECORD, not VELOCITY. Velocity is selected by TYPE=VELOCITY (upstream README).
- Chart sets RCON_PORT to 25578 while upstream Dockerfile default is 25575.
