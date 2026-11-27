# TrueCharts chart: rtorrent-rutorrent

Source URL(s) + date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/rtorrent-rutorrent/Chart.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/rtorrent-rutorrent/values.yaml (fetched 2026-11-27)

## What it is
- Chart v10.0.0, appVersion 4.2.9. Category torrent. "rTorrent and ruTorrent chart."
- Sources: ghcr.io/crazy-max/rtorrent-rutorrent, ghcr.io/thde/rtorrent_exporter, github crazy-max/docker-rtorrent-rutorrent.
- Deps: common 32.8.5 (oci://oci.trueforge.org/truecharts)

## Image (values.yaml)
- main: `ghcr.io/crazy-max/rtorrent-rutorrent`, tag `4.2.9-0.9.8_2-0.13.8_1@sha256:8d089b00...aef9`
- exportarr sidecar: `ghcr.io/thde/rtorrent_exporter`, tag `v1.3.2@sha256:dac13545...b494`

## Ports
| service | port | protocol |
| --- | --- | --- |
| main | 8080 | http |
| rtorrent | 33942 | tcp |
| xmlrpc | 8000 | http |
| dht | 6881 | udp |
| webdav | 9000 | http |
| rtinc | 50000 | tcp (default) |
| metrics | 9135 | ClusterIP (exporter) |

## Env (container main, set by chart)
| key | value |
| --- | --- |
| RUTORRENT_PORT | service main port (8080) |
| PORT_RTORRENT | 33942 |
| RT_DHT_PORT | 6881 |
| XMLRPC_PORT | 8000 |
| WEBDAV_PORT | 9000 |
| RT_INC_PORT | 50000 |

Exporter env: INTERFACE=0.0.0.0, PORT=9135, URL=http://<release>-xmlrpc.<ns>:8000/RPC2/, ENABLE_ADDITIONAL_METRICS=false, ENABLE_UNKNOWN_QUEUE_ITEMS=false.

## Probes
- main liveness/readiness/startup: exec `/usr/local/bin/healthcheck`
- exporter probes disabled.

## Persistence (mountPaths)
| name | mountPath |
| --- | --- |
| data | /data |
| downloads | /downloads |
| passwd | /passwd |

## Security context (chart)
- PUID 33, runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false (chart defaults; not rootless).

## Metrics
- servicemonitor, endpoint port `metrics` path `/metrics`.

## Upstream Dockerfile (crazy-max @1efb9e0, v4.2.9)
Source URL: https://raw.githubusercontent.com/crazy-max/docker-rtorrent-rutorrent/1efb9e087f90f68ed132b3ffd419b29145a1838e/Dockerfile (fetched 2026-11-27)
- Base: `crazymax/alpine-s6` at alpine 3.19 (s6 tag `3.19-2.2.0.3`). Multi-stage: builder + runtime.
- Build versions (ARG): libsigc++ 3.0.3, c-ares 1.24.0, curl 8.5.0, xmlrpc-c 01.58.00 (crazy-max fork), libtorrent v0.13.8, rtorrent v0.9.8 (rakshasa), mktorrent v1.1, geoip2-phpext 1.3.1, ruTorrent e7c81203 (v4.2.9), geoip2-rutorrent 4ff2bde5.
- Sources fetched at build from git/curl: download.gnome.org, c-ares.org, curl.se, github (crazy-max/xmlrpc-c, rakshasa/libtorrent, rakshasa/rtorrent, esmil/mktorrent, rlerdorf/geoip, Novik/ruTorrent, Micdu70/geoip2-rutorrent), github crazy-max/geoip-updater mmdb files.
- Patches from `patches/libtorrent` (throttle-fix-0.13.8.patch) and `patches/rtorrent` (lockfile-fix, rtorrent-scrape, scgi-fix, session-file-fix, xmlrpc-fix, xmlrpc-logic-fix).
- Runtime: php82 (fpm, bcmath, curl, mbstring, xml, zip, etc.), nginx + dav-ext + geoip2, apache2-utils, ffmpeg, mediainfo, unrar@314 (from alpine v3.14 repo), python3 + cfscrape/cloudscraper via pip.
- ENV: PUID=1000, PGID=1000, TZ=UTC, S6_BEHAVIOUR_IF_STAGE2_FAILS=2, S6_KILL_GRACETIME=10000, PYTHONPATH adds /var/www/rutorrent.
- User: group/user `rtorrent` created with PGID/PUID (defaults 1000).
- ruTorrent at /var/www/rutorrent; mmdb at /var/mmdb.
- VOLUME: /data, /downloads, /passwd. ENTRYPOINT `/init`. HEALTHCHECK `/usr/local/bin/healthcheck` every 30s.
- `COPY rootfs /` supplies init scripts (not fetched).

## Gotchas
- Chart sets PUID=33 and runs as root (runAsUser 0); upstream image default PUID/PGID is 1000.
- Chart's xmlrpc/rtorrent ports are internal-facing; exporter scrapes xmlrpc.
