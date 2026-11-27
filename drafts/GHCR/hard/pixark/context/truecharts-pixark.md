# TrueCharts chart: pixark

**Source URL(s):** https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/pixark/values.yaml , .../Chart.yaml · fetched 2026-11-27

## What it is
- Chart `pixark` v11.0.0, appVersion `pixark` (string, not a version), train stable, category GameServers.
- Dependency: `common` 32.8.5. kubeVersion >=1.33.0-0.
- Description: installs SteamCMD and PIXARK; first server start can take a long time.

## Image
- repository: `ghcr.io/ich777/steamcmd`
- tag: `pixark@sha256:311562a4...694af1` (pullPolicy IfNotPresent)

## Ports
| name | port | target | proto |
| --- | --- | --- | --- |
| main | 27015 | 27015 | udp (game) |
| queryport | 27016 | 27016 | udp (query) |
| cubeport | 27018 | 27018 | udp (cube) |

## Env (chart-set)
| var | value |
| --- | --- |
| GAME_ID | 824360 (Steam app id) |
| GAME_PARAMS | `?MaxPlayers=10` |
| GAME_PARAMS_EXTRA | `-QueryPort=27016 -Port=27015 -CubePort=27018 -NoBattlEye -nosteamclient -game -server -log` |
| MAP | CubeWorld_Light |
| SERVER_NAME | PIXARKDocker |
| USERNAME | "" (anonymous) |
| VALIDATE | "false" |
| PASSWRD | secretKeyRef env-secrets/PASSWRD |
| SRV_PWD | secretKeyRef env-secrets/SRV_PWD |
| SRV_ADMIN_PWD | secretKeyRef env-secrets/SRV_ADMIN_PWD |

Secret `env-secrets` placeholder values: PASSWRD "", SRV_PWD "Docker", SRV_ADMIN_PWD "adminDocker".

## Persistence
| name | mountPath |
| --- | --- |
| serverfiles | /serverdata/serverfiles |
| steamcmd | /serverdata/steamcmd |

## Probes
- liveness, readiness, startup all disabled.

## Security context (chart)
- runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.

## Gotchas
- Ports are UDP only (game/query/cube).
- Chart runs as root with steamcmd persistence under /serverdata.
