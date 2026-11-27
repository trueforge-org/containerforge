# TrueCharts makemkv (stable)

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/makemkv/{Chart.yaml,values.yaml} · fetched 2026-11-27

## What it is
- Chart `makemkv` v18.1.1, appVersion 26.11.2
- Description: MakeMKV, converts owned video discs to MKV

## Image
- repository ghcr.io/jlesage/makemkv, tag v26.11.2 (digest pinned), pullPolicy IfNotPresent

## Env vars (configmap `makemkv` via envFrom, plus secret)
| Var | Chart default |
| --- | --- |
| KEEP_APP_RUNNING | "0" (false) |
| DISPLAY_WIDTH | 1280 |
| DISPLAY_HEIGHT | 768 |
| DARK_MODE | "0" |
| MAKEMKV_KEY | BETA |
| AUTO_DISC_RIPPER_INTERVAL | 5 |
| AUTO_DISC_RIPPER_BD_MODE | mkv |
| AUTO_DISC_RIPPER_MAKEMKV_PROFILE | "" |
| SECURE_CONNECTION | "0" |
| ENABLE_CJK_FONT | "0" |
| AUTO_DISC_RIPPER | "0" |
| AUTO_DISC_RIPPER_EJECT | "0" |
| AUTO_DISC_RIPPER_PARALLEL_RIP | "0" |
| AUTO_DISC_RIPPER_NO_GUI_PROGRESS | "0" |
| AUTO_DISC_RIPPER_FORCE_UNIQUE_OUTPUT_DIR | "0" |
| VNC_PASSWORD | secret env-secrets |

## Ports
| Service | Port | Target |
| --- | --- | --- |
| main | 10180 | 5800 (web GUI) |
| vnc | 10181 | 5900 |

## Volumes/paths
| Name | Mount |
| --- | --- |
| config | /config |
| storage | /storage |
| output | /output |
| varrun | disabled |

## User/UID
- securityContext: runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false
- capabilities add: NET_BIND_SERVICE, KILL

## Healthcheck
- tcp liveness, readiness, startup

## Gotchas
- Optical drive access expected (lsscsi, sg3_utils in image).
