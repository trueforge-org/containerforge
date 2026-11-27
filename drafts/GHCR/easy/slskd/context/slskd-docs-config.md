# slskd docs/config.md

## Source URL(s) + date
- https://raw.githubusercontent.com/slskd/slskd/master/docs/config.md (master branch, not 0.26.2)
- Fetched 2026-11-27

## Config file
- Path `<APP_DIR>/slskd.yml`; override `SLSKD_CONFIG` or `--config`. YAML, live-reloaded.
- If absent at startup, `/config/slskd.example.yml` is copied into place (per page).
- Precedence low→high: defaults < env vars < YAML < CLI args < runtime overlay.

## Env vars
- Every name starts `SLSKD_`, e.g. `SLSKD_SLSK_USERNAME`, `SLSKD_HTTP_PORT`. No `__` nesting rule documented.
- Lists separated by `;`.

## Ports
| Port | Default | Env / CLI / YAML |
| --- | --- | --- |
| Web HTTP | 5030 | `SLSKD_HTTP_PORT`, `web.port` |
| Web HTTPS | 5031 | `SLSKD_HTTPS_PORT` |
| Soulseek listen | 50300 | `SLSKD_SLSK_LISTEN_PORT`, `soulseek.listen_port`; IP default `0.0.0.0` |
- Soulseek server: vps.slsknet.org:2271

## App directory
- `APP_DIR` env (page name) or `--app-dir`. Not settable in YAML.
- Defaults: `~/.local/share/slskd` (Linux/macOS), `/app` in official Docker image. Holds logs and SQLite DBs.

## Downloads / incomplete / shares
- Default `APP_DIR/downloads` and `APP_DIR/incomplete` (created at startup only at defaults; custom paths must exist and be writable).
- `SLSKD_DOWNLOADS_DIR` / YAML `directories.downloads`; `SLSKD_INCOMPLETE_DIR` / `directories.incomplete`.
- Shares: `SLSKD_SHARED_DIR` / YAML `shares.directories` (list, no default). Absolute paths only. Prefix `-` or `!` to exclude.

## Defaults / gotchas
- Soulseek username and password required.
- Web UI login defaults to `slskd`/`slskd`.
- Page names the app-dir variable `APP_DIR`; upstream Dockerfile sets `SLSKD_APP_DIR=/app`. Conflict, see README.
