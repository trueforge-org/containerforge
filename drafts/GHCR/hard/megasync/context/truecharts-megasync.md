# TrueCharts megasync (stable)

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/megasync/{Chart.yaml,values.yaml} · fetched 2026-11-27

## What it is
- Chart `megasync` v12.0.0, appVersion `latest`
- Description: MEGAsync syncs devices with a MEGA account

## Image
- repository ghcr.io/ich777/megasync, tag latest (digest pinned), pullPolicy IfNotPresent

## Env vars (workload main)
| Var | Value |
| --- | --- |
| DATA_DIR | persistence.data mountPath (/data) |
| CUSTOM_RES_H | "600" |
| CUSTOM_RES_W | "800" |

## Ports
| Service | Port | Protocol | Target |
| --- | --- | --- | --- |
| main | 8080 | http | 8080 |

## Volumes/paths
| Name | Mount | Notes |
| --- | --- | --- |
| data | /data | persistent |
| hostpath | /mnt/host | read-only (enabled) |

## User/UID
- securityContext: runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false

## Healthcheck
- Not overridden in values

## Gotchas
- Chart tag is `latest` (no pinned version string).
