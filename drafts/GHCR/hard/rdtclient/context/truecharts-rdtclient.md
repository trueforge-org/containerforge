# TrueCharts chart: rdtclient

**Source URL(s):** https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/rdtclient/values.yaml , .../Chart.yaml · fetched 2026-11-27

## What it is
- Chart `rdtclient` (appVersion 2.0.143), train stable, category media.
- Description: web UI to manage torrents on Real-Debrid, AllDebrid or Premiumize.
- Two-container pod: main (rdtclient) + `aria2` sidecar (Deployment). Dependency: `common` 32.8.5.

## Images
| role | repository | tag |
| --- | --- | --- |
| main | `ghcr.io/rogerfar/rdtclient` | `2.0.143@sha256:68523637...ff36` |
| aria2 | `ghcr.io/p3terx/aria2-pro` | `latest@sha256:086d1a37...c9a011` |

## Ports
| service | name | port | target | proto |
| --- | --- | --- | --- | --- |
| main | main | 6500 | 6500 | http |
| aria2 | rpc | 6800 | RPC_PORT | tcp (ClusterIP) |
| torrent | torrent | 6888 | LISTEN_PORT | tcp (ClusterIP) |
| torrent | torrent-udp | 6888 | - | udp |

## Env (aria2 container, chart-set)
| var | value |
| --- | --- |
| RPC_PORT | 6800 (from service.aria2.ports.rpc) |
| LISTEN_PORT | 6888 (from service.torrent.ports.torrent) |
| RPC_SECRET | secret env-secrets/RPC_SECRET (value `MY_SECRET`) |
| DISK_CACHE | 64M |
| IPV6_MODE | false |
| UPDATE_TRACKERS | true |
| CUSTOM_TRACKER_URL | https://trackerslist.com/all_aria2.txt |

## Persistence
| name | mountPath | where |
| --- | --- | --- |
| db | /data/db | main |
| config | /config | aria2 container (targetSelector aria2) |

## Probes
- main: liveness, readiness, startup HTTP path `/`.
- aria2: liveness, readiness, startup TCP on RPC port (6800).

## Security context (chart)
- main and aria2: runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false, runAsNonRoot false.

## Gotchas
- aria2 `rpc_secret` default in values is `MY_SECRET`; must be overridden.
- Probes use the aria2 RPC port for TCP.
