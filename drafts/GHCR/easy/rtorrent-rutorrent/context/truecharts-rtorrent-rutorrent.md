# TrueCharts rtorrent-rutorrent chart

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/rtorrent-rutorrent/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/rtorrent-rutorrent/Chart.yaml
- Fetched 2026-11-27

## What it is
- "rTorrent and ruTorrent chart." Chart 10.0.0, appVersion 4.2.9, keywords rutorrent/torrent
- Dependency: `common` 32.8.5 (oci://oci.trueforge.org/truecharts)
- Chart sources: ghcr.io/crazy-max/rtorrent-rutorrent, ghcr.io/thde/rtorrent_exporter, github crazy-max/docker-rtorrent-rutorrent

## Images (values.yaml)
| Role | Repository | Tag |
| --- | --- | --- |
| main | ghcr.io/crazy-max/rtorrent-rutorrent | 4.2.9-0.9.8_2-0.13.8_1@sha256:8d089b00282a203886361268d9210106956302c2194e75ae56982a6f0398aef9 |
| exportarr (sidecar) | ghcr.io/thde/rtorrent_exporter | v1.3.2@sha256:dac13545d02d5f36d03d4ef0c75d11b9333334b2ce9a0fa701eba800a795b494 |

## Security context
- PUID 33 (in securityContext.container), runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false

## Services
| Service | Port | Proto | Note |
| --- | --- | --- | --- |
| main | 8080 | http | ruTorrent UI |
| rtorrent | 33942 | tcp | PORT_RTORRENT |
| xmlrpc | 8000 | http | XMLRPC_PORT |
| dht | 6881 | udp | RT_DHT_PORT |
| webdav | 9000 | http | WEBDAV_PORT |
| rtinc | 50000 | tcp (no proto set) | RT_INC_PORT |
| metrics | 9135 | ClusterIP | exporter, enabled from metrics.main |

## Main env (workload.main)
| Name | Value |
| --- | --- |
| RUTORRENT_PORT | service main port (8080) |
| PORT_RTORRENT | 33942 |
| RT_DHT_PORT | 6881 |
| XMLRPC_PORT | 8000 |
| WEBDAV_PORT | 9000 |
| RT_INC_PORT | 50000 |

## Probes (main)
- liveness, readiness, startup: exec `/usr/local/bin/healthcheck`

## Exporter sidecar (workload.exportarr container)
- imageSelector exportarrImage; enabled from metrics.main.enabled (true)
- arg: `--rtorrent.scrape-uri=http://<release>-xmlrpc.<ns>:8000/RPC2/`
- env: INTERFACE 0.0.0.0, PORT 9135, URL (xmlrpc scrape URL), ENABLE_ADDITIONAL_METRICS false, ENABLE_UNKNOWN_QUEUE_ITEMS false
- probes disabled

## Persistence
| Name | Mount |
| --- | --- |
| data | /data |
| downloads | /downloads |
| passwd | /passwd |

## Metrics
- ServiceMonitor, endpoint port `metrics`, path /metrics; prometheusRule disabled

## Gotchas
- PUID 33 in the chart's securityContext, while the image default PUID/PGID is 1000 (see `crazy-max-rtorrent-rutorrent-dockerfile.md` and README).
