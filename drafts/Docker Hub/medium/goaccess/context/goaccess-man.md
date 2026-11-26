# GoAccess man page (goaccess.io/man)

Source URL(s): https://goaccess.io/man
Date: fetched 2026-11-26

| Option | Facts |
| --- | --- |
| `--log-format` | Format string or predefined: COMBINED, VCOMBINED, COMMON, CADDY, AWSALB. Required with piped input (no config dialog). |
| `-f`, `--log-file` | Input log path. Config-file value takes priority over CLI. |
| `-o`, `--output` | Output `.csv`, `.json` or `.html`; repeatable. |
| `--real-os` | Real OS names. |
| `-p`, `--config-file` | Custom config file (takes priority over global). |
| `--no-global-config` | Skip `/etc/`, `/usr/etc/`, `/usr/local/etc/` global config. |
| `--daemonize` | Daemon; only with `--real-time-html`. Pair with `--pid-file`. |
| `--port` | WebSocket server port, default 7890. |
| `--addr` | Bind address, default `0.0.0.0`. |
| `--ws-url` | URL clients use for websocket (ws:// or wss://, proxy path if any). |
| `--geoip-database` | GeoIP DB path (repeatable; alias `--geoip-city-data`). Needs `--enable-geoip` at compile. |
| `--db-path` | On-disk DB dir, default `/tmp`. |
| `--persist` | Save parsed data (overwrites DB files). |
| `--restore` | Load stored data (files must exist; http-method/protocol must match). |
| `-a`, `--agent-list` | Per-host user-agent list (slower). |
| `-g`, `--std-geoip` | Standard GeoIP DB (legacy). |

- Env: `GOACCESS_WSAUTH_SECRET` (JWT secret for `--ws-auth=jwt`); `LC_TIME` (English month names).
- Config locations: `%sysconfdir%/goaccess.conf` or `~/.goaccessrc`; `--dcf` shows default.
- `--real-time-html` needed for live HTML; TLS needs `--ssl-cert`/`--ssl-key` and `--with-openssl` build.
- `.gz` input needs `--with-zlib` build.
