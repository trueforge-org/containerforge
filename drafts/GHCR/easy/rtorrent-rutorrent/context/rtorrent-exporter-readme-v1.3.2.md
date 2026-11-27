# thde rtorrent_exporter README and flags (v1.3.2)

## Source URL(s) + date
- https://raw.githubusercontent.com/thde/rtorrent_exporter/v1.3.2/README.md (fetched 2026-11-27)
- Repo: https://github.com/thde/rtorrent_exporter (root not fetched separately, README used)

## Flags (from README usage) and env equivalents
| Flag | Default | Env |
| --- | --- | --- |
| --web.listen-address | :9135 | RTORRENT_EXPORTER_WEB_LISTEN_ADDRESS |
| --web.telemetry-path | /metrics | RTORRENT_EXPORTER_WEB_TELEMETRY_PATH |
| --web.config.file | "" | RTORRENT_EXPORTER_WEB_CONFIG_FILE |
| --rtorrent.scrape-uri | http://localhost/RPC2 | RTORRENT_EXPORTER_RTORRENT_SCRAPE_URI (basic auth via user:pass in URI) |
| --rtorrent.ssl-verify | not shown (--[no-] flag) | RTORRENT_EXPORTER_RTORRENT_SSL_VERIFY |
| --rtorrent.timeout | 5s | RTORRENT_EXPORTER_RTORRENT_TIMEOUT |
| --log.level | info | RTORRENT_EXPORTER_LOG_LEVEL |
| --log.format | logfmt (logfmt or json) | RTORRENT_EXPORTER_LOG_FORMAT |

- Help env: RTORRENT_EXPORTER_HELP; version: RTORRENT_EXPORTER_VERSION

## Install
- Binaries on GitHub releases; container `ghcr.io/thde/rtorrent_exporter:latest` (README)

## Gotchas
- Scrape URL must point at rTorrent's XMLRPC/SCGI-over-HTTP RPC2 endpoint (chart uses xmlrpc service port 8000 path /RPC2/).
