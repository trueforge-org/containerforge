# TrueCharts backuppc (chart 13.0.0)

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/backuppc/{values.yaml,Chart.yaml} (fetched 2026-11-27)

## What it is
- Chart `backuppc` 13.0.0, appVersion 4.0.0 (chart value; image tag is 4, upstream BackupPC 4.4.0 built into image), common 32.8.5.
- Description: enterprise-grade backup system for Linux, Windows, macOS PCs to server disk.
- Chart sources: ghcr.io/adferrand/backuppc, github adferrand/docker-backuppc, backuppc.github.io.

## Image
- repository: `ghcr.io/adferrand/backuppc`
- tag: `4@sha256:0c4bb8f0c2992cfa29ad28ed5ee2b99861f901d31400f2c73040994aac26d34f`
- pullPolicy: IfNotPresent

## Ports
| Name | Protocol | Port |
| --- | --- | --- |
| main | tcp | 8080 |

## Security context
- runAsNonRoot: false, readOnlyRootFilesystem: false, runAsUser 0, runAsGroup 0.

## Env (chart)
| Env | Value |
| --- | --- |
| BACKUPPC_UUID | `{{ .Values.securityContext.container.PUID }}` (key not set in values; renders empty) |
| BACKUPPC_GUID | `{{ .Values.securityContext.pod.fsGroup }}` (key not set in values; renders empty) |

## Persistence
| Name | mountPath |
| --- | --- |
| config | /etc/backuppc |
| ssh | /home/backuppc |
| data | /data/backuppc |

## Gotchas
- The BACKUPPC_UUID/GUID templates reference keys not defined in this values.yaml (PUID / pod.fsGroup). Whether they render empty depends on common chart defaults (not checked).
