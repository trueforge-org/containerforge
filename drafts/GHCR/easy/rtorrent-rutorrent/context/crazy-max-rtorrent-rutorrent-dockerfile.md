# crazy-max docker-rtorrent-rutorrent Dockerfile (master)

## Source URL(s) + date
- https://raw.githubusercontent.com/crazy-max/docker-rtorrent-rutorrent/master/Dockerfile (fetched 2026-11-27; not in the list, added as the image build source)
- Repo root https://github.com/crazy-max/docker-rtorrent-rutorrent: covered by this file and README
- README: https://raw.githubusercontent.com/crazy-max/docker-rtorrent-rutorrent/master/README.md (grepped, 2026-11-27)

## Versions (ARG, renovate-annotated)
| ARG | Value |
| --- | --- |
| CARES_VERSION | 1.34.9 (c-ares) |
| CURL_VERSION | 8.23.0 |
| LIBTORRENT_VERSION | v0.16.28 |
| RTORRENT_VERSION | v0.16.28 |
| MKTORRENT_VERSION | v1.1 |
| RUTORRENT_VERSION | v5.3.25 |
| DUMPTORRENT_VERSION | v1.7.0 |
| UNRAR_VERSION | 7.3.2 |
| ALPINE_VERSION | 3.24 |

## Build stages
- Sources: c-ares and curl tarballs; libtorrent, rtorrent, mktorrent, ruTorrent, dumptorrent via git fetch of tag; unrar tarball from rarlab; GeoIP2 plugin via composer; GeoLite2 City + Country mmdb from github crazy-max/geoip-updater (mmdb branch)
- Builder (alpine): cmake c-ares and curl (ENABLE_ARES, OpenSSL, brotli, zstd), autotools libtorrent and rtorrent (xmlrpc-tinyxml2, ncurses), mktorrent, dumptorrent, unrar; installed into `/dist`
- Final image `alpine:3.24`: gosu from tianon/gosu, s6-overlay, nginx (dav-ext, geoip2), php85 + php-fpm, ffmpeg, mediainfo, python3 with cfscrape/cloudscraper, apache2-utils, etc.
- `addgroup -g ${PGID} rtorrent`, `adduser -D -H -u ${PUID} -G rtorrent -s /bin/sh rtorrent`

## Runtime
- ENV: PYTHONPATH=/var/www/rutorrent, S6_BEHAVIOUR_IF_STAGE2_FAILS=2, S6_STAGE2_HOOK=/etc/s6-overlay/scripts/runtime-bundles, TZ=UTC, PUID=1000, PGID=1000
- sysctl additions: net.core.rmem_max and wmem_max = 67108864 (written to /etc/sysctl.conf)
- `COPY rootfs /`; `VOLUME ["/data", "/downloads", "/passwd"]`
- `ENTRYPOINT ["/init"]` (s6-overlay)
- HEALTHCHECK every 30s, timeout 20s, start-period 10s: `/usr/local/bin/healthcheck`

## Env (README, defaults)
| Name | Default |
| --- | --- |
| PUID | 1000 |
| PGID | 1000 |
| XMLRPC_PORT | 8000 |
| RUTORRENT_PORT | 8080 |
| WEBDAV_PORT | 9000 |
| RT_DHT_PORT | 6881 |
| RT_INC_PORT | 50000 |
| RT_SEND_BUFFER_SIZE / RT_RECEIVE_BUFFER_SIZE | 4M |
| RT_LOG_GROUPS | errors,events |
| RT_SESSION_SAVE_SECONDS | 3600 |
| RU_SAVE_UPLOADED_TORRENTS | true |
| RU_FORBID_USER_SETTINGS | false |
| RUTORRENT_AUTHBASIC_STRING | "ruTorrent restricted access" |

## Volumes
| Path | Use |
| --- | --- |
| /data | rTorrent/ruTorrent config, sessions, logs |
| /downloads | downloaded files |
| /passwd | htpasswd files for basic auth |

## Ports (README)
- 6881 (RT_DHT_PORT, UDP), 8000 (XMLRPC_PORT), 8080 (RUTORRENT_PORT), 9000 (WEBDAV_PORT), 50000 (RT_INC_PORT). Port p+1 for XMLRPC, RUTORRENT, WEBDAV is reserved for healthcheck.

## User/UID
- rtorrent uid/gid from PUID/PGID (default 1000); README: set PUID/PGID to match volume ownership; `chown ${PUID}:${PGID} data downloads passwd`

## Gotchas
- Volumes must be owned by PUID:PGID or the service fails (README).
- Reserved p+1 ports for healthcheck.
