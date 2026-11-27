# TrueCharts lancache-monolithic (stable)

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/lancache-monolithic/{Chart.yaml,values.yaml} · fetched 2026-11-27

## What it is
- Chart `lancache-monolithic` v14.0.0, appVersion `latest`
- Description: monolithic lancache service caching all CDNs in one instance

## Images
| Role | Repository | Tag |
| --- | --- | --- |
| main | docker.io/lancachenet/monolithic | latest (digest pinned) |
| prefill sidecar | ghcr.io/ich777/lancache-prefill | latest (digest pinned) |

## Env vars (main)
| Var | Source value |
| --- | --- |
| CACHE_DOMAINS_REPO | https://github.com/uklans/cache-domains.git |
| CACHE_DOMAINS_BRANCH | master |
| UPSTREAM_DNS | 1.1.1.1 1.0.0.1 |
| CACHE_DISK_SIZE | 1000000m |
| CACHE_MAX_AGE | 3560d |
| CACHE_INDEX_SIZE | 500m |
| NOFETCH | false |

## Env vars (prefill sidecar)
| Var | Default in chart |
| --- | --- |
| DATA_DIR | persistence.prefill mountPath (/data/prefill) |
| UPDATES | true |
| PREFILL_ONSTARTUP | false |
| LOGCLEANUP | true |
| CRON_SCHED_GLOBAL | "" |
| ENABLE_BN / ENABLE_EPIC / ENABLE_STEAM | true / true / true |
| CRON_SCHED_BN / EPIC / STEAM | "0 5 * * *" / "0 4 * * *" / "0 2 * * *" |
| PREFILL_PARAMS_BN/EPIC/STEAM | "" (lists, empty) |
| DATA_PERM | 770 |
| USER | root |

## Ports
| Service | Port | Target |
| --- | --- | --- |
| main | 10279 http | 80 |
| https | 10280 https | 443 (enabled) |

## Volumes/paths
| Name | Mount |
| --- | --- |
| config | /data/cache |
| logs | /data/logs |
| prefill | /data/prefill (targetSelectAll) |

## User/UID
- securityContext.container: runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false

## Healthcheck
- main: tcp liveness/readiness/startup
- prefill: all probes disabled

## Gotchas
- Prefill is a Deployment sidecar with tty/stdin true.
- Prefill runs as USER root in chart env.
