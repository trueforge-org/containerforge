# slskd README (master)

## Source URL(s) + date
- https://raw.githubusercontent.com/slskd/slskd/master/README.md
- Fetched 2026-11-27

## What it is
- Client-server app for the Soulseek network; web UI; built to be internet-exposed (token-protected); works behind reverse proxies.

## Docker (per README)
- Image `slskd/slskd` (README; TrueCharts and plan use `ghcr.io/slskd/slskd`), tag `latest` shown.
- Ports: 5030 (HTTP web UI), 5031 (HTTPS, self-signed), 50300 (incoming Soulseek).
- Volume: `<data>:/app` (application directory).
- Run user: `--user 1000:1000`, or `PUID`/`PGID` env alternative.
- `SLSKD_REMOTE_CONFIGURATION=true` enables settings changes from the web UI (warned against on internet-facing installs).
- Web login defaults `slskd`/`slskd`.
- Data dir defaults: `~/.local/share/slskd` (Linux/macOS), `%localappdata%/slskd` (Windows).
- Binaries: release zips on GitHub; architectures not listed.

## Gotchas
- README example and TrueCharts use different image namespaces (`slskd/slskd` vs `ghcr.io/slskd/slskd`).
