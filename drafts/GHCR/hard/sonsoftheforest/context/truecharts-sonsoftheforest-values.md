# TrueCharts sonsoftheforest values.yaml
Source URL: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/sonsoftheforest/values.yaml (fetched 2026-11-27)

## Image
- repository `ghcr.io/ich777/steamcmd`
- tag `sonsoftheforest@sha256:fc451cd409dc22b2cd47490e20c226fadf6af3aae283445339c68cb57d915260`
- pullPolicy IfNotPresent

## Security context
- runAsNonRoot false, readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0

## Ports (service)
| name | proto | port | notes |
| --- | --- | --- | --- |
| main | udp | 8766 | game port |
| query | udp | 27016 | enabled |
| sync | udp | 9700 | BlobSyncPort, enabled |

## Game (values `sonsoftheforest.game`)
- id `"2465200"` (passed as GAME_ID), user "", password "", validate false, params []

## Server settings (values `sonsoftheforest.server`, rendered into dedicatedserver.cfg)
- IpAddress 0.0.0.0, GamePort = main port, QueryPort = query port, BlobSyncPort = sync port
- ServerName "Sons Of The Forest Docker Server", MaxPlayers 8, Password "", LanOnly false
- SaveSlot 1, SaveMode "continue" (new|continue), GameMode "normal" (peaceful|normal|hard|hardsurvival|custom), SaveInterval 600
- IdleDayCycleSpeed "0.0", IdleTargetFramerate 5, ActiveTargetFramerate 60
- LogFilesEnabled false, TimestampLogFilenames true, TimestampLogEntries true, SkipNetworkAccessibilityTest false
- GameSettings: Gameplay.TreeRegrowth true, Structure.Damage true
- CustomGameModeSettings: many GameSetting.* keys (Vail/Environment/Survival); low|normal|high or off|normal|hard style enums

## Env (container `main`, workload.main)
| env | value |
| --- | --- |
| GAME_PORT | main port (8766) |
| STEAMCMD_DIR | persistence.steamcmd.mountPath |
| SERVER_DIR | persistence.serverfiles.mountPath |
| GAME_ID | sonsoftheforest.game.id |
| USERNAME | sonsoftheforest.game.user |
| PASSWRD | secretKeyRef env-secrets/PASSWRD |
| GAME_PARAMS | join of game.params |
| VALIDATE | game.validate |

Probes: liveness, readiness, startup all disabled.

## Persistence
| name | mountPath | notes |
| --- | --- | --- |
| steamcmd | /serverdata/steamcmd | enabled |
| serverfiles | /serverdata/serverfiles | enabled |
| dedicatedserver-dscfg | /serverdata/serverfiles/userdata/dedicatedserver.cfg | configmap `sonsoftheforest-dscfg`, subPath dedicatedserver.cfg, readOnly, on main/main |

## Secret
- `env-secrets` with key PASSWRD (from game.password)
