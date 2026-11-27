# TrueCharts krusader (stable)

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/krusader/{Chart.yaml,values.yaml} · fetched 2026-11-27

## What it is
- Chart `krusader` v11.0.0, appVersion `latest`
- Description: Krusader, orthodox two-pane file manager for KDE (archive handling, FTP, search, sync, batch rename)

## Image
- repository ghcr.io/ich777/krusader, tag latest (digest pinned), pullPolicy IfNotPresent

## Env vars (workload main)
| Var | Value |
| --- | --- |
| CUSTOM_RES_H | "768" |
| CUSTOM_RES_W | "1280" |
| NOVNC_RESIZE | remote |
| RUNASROOT | "false" |
| USER_LOCALES | en_US.UTF-8 UTF-8 |

## Ports
| Service | Port | Protocol |
| --- | --- | --- |
| main | 8080 | tcp (noVNC web) |

## Volumes/paths
| Name | Mount |
| --- | --- |
| containerpath | /krusader |
| datapath | /mnt/user |

## User/UID
- securityContext: runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false
- chart sets RUNASROOT=false

## Healthcheck
- Not set in values (no probes override).

## Gotchas
- Tag is `latest` with a digest pin; no fixed version string.
