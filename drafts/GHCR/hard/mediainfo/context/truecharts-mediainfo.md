# TrueCharts mediainfo (stable)

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/mediainfo/{Chart.yaml,values.yaml} · fetched 2026-11-27

## What it is
- Chart `mediainfo` v17.1.1, appVersion 26.11.2
- Description: unified display of technical and tag data for video and audio files

## Image
- repository ghcr.io/jlesage/mediainfo, tag v26.11.2 (digest pinned), pullPolicy IfNotPresent

## Env vars (configmap `mediainfo` via envFrom, plus secret)
| Var | Chart default |
| --- | --- |
| KEEP_APP_RUNNING | "0" |
| DISPLAY_WIDTH | 1280 |
| DISPLAY_HEIGHT | 768 |
| SECURE_CONNECTION | "0" |
| ENABLE_CJK_FONT | "0" |
| VNC_PASSWORD | secret env-secrets (default "") |

## Ports
| Service | Port | Target |
| --- | --- | --- |
| main | 10264 | 5800 (web GUI) |
| vnc | 10265 | 5900 |

## Volumes/paths
| Name | Mount |
| --- | --- |
| config | /config |
| storage | /storage |
| varrun | disabled |

## User/UID
- securityContext: runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false
- capabilities add: NET_BIND_SERVICE, KILL

## Healthcheck
- tcp liveness, readiness, startup

## Gotchas
- None beyond the root/caps settings above.
