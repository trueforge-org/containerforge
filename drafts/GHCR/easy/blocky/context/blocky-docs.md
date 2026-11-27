# Blocky docs (configuration.md and docs/config.yml, master branch)

## Source URL(s) + date
- https://raw.githubusercontent.com/0xERR0R/blocky/master/docs/configuration.md (fetched 2026-11-27)
- https://raw.githubusercontent.com/0xERR0R/blocky/master/docs/config.yml (fetched 2026-11-27)
- https://0xerr0r.github.io/blocky (fetched 2026-11-27; redirect stub to `latest/`, no content)

## Ports & addresses (config keys)
| Key | Default | Notes |
| --- | --- | --- |
| ports.dns | 53 | TCP and UDP. Accepts `53`, `:53`, `IP:port` |
| ports.tls | empty | DoT, example 853 |
| ports.https | empty | HTTPS, example 443 |
| ports.http | empty | metrics, pprof, REST API, DoH, example 4000 |
| ports.dohPath | /dns-query | |
| ports.freeBind | false | Linux IP_FREEBIND |

## Healthcheck
- Probe: `dig @127.0.0.1 -p 53 healthcheck.blocky +short +tries=1` (docs example for Docker Compose). Probes check NOERROR status, not records.
- Upstream Dockerfile HEALTHCHECK uses `/app/blocky healthcheck` instead.

## Cache
- `cachePath` (default empty): on-disk cache of downloaded sources.
- Docker: blocky runs as UID 100; use `/app/cache` (pre-created in image) with a named volume, example `cachePath: /app/cache`.
- Example in config.yml: `cachePath: /var/cache/blocky/lists` (commented).

## Logs
- `log.level` (default info; trace, debug, info, warn, error); `log.privacy` (false).
- `queryLog.type`: one of mysql, postgresql, timescale, sqlite, csv, csv-client, dnstap. Empty = log to console.
- Docker csv/log example target: `/logs`.

## Config file
- `BLOCKY_CONFIG_FILE` env (Docker); `--config` may point to a file or folder.

## Gotchas
- Port 53 needs CAP_NET_BIND_SERVICE when non-root (docs / plan); upstream default is 53.
- HTTP/3 (http3.enable) requires ports.https; not default.
- queryLog target/DSN is per type (e.g. postgres:// DSN, csv dir).
