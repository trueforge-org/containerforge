# Docker Hub: feramance/qbitrr

Source URL(s):
- https://hub.docker.com/v2/repositories/feramance/qbitrr/
- https://hub.docker.com/v2/repositories/feramance/qbitrr/tags?page_size=10
Fetched: 2026-11-27

## Repository
| Key | Value |
| --- | --- |
| description | qBitrr keeps qBittorrent, Radarr, Sonarr, and request tools in sync |
| pull_count | 279380 |
| last_updated | 2026-11-23 |
| tag count | 753 |
| platforms | amd64, arm64 (multi-arch OCI index tags) |

## Tags (page_size=10, newest first)
| Tag | Arch | Last pushed |
| --- | --- | --- |
| latest (index) | amd64, arm64 | 2026-11-23 |
| nightly (index) | amd64, arm64 | 2026-11-23 |
| v5.14.9-4 (index, same digest as latest) | amd64, arm64 | 2026-11-23 |
- v5.12.12 (chart pin) is not on the first tags page; its digest 60843fc5... not verified against Hub.

## Run (README)
- `docker run -d --name qbitrr --tty -e TZ=Europe/London -p 6969:6969 -v /path/to/appdata/qbitrr:/config -v /path/to/completed/downloads:/completed_downloads:rw --restart unless-stopped feramance/qbitrr:stable`
- WebUI: `http://<host>:6969/ui`.
- Tag guidance: `:stable` for production; `:latest` includes weekly dependency builds; `:nightly` tracks master.
- Config: Docker `/config/config.toml`; native `.config/config.toml` or path from `QBITRR_OVERRIDES_DATA_PATH`.

## Gotchas
- README references `:stable` tag; the first page of tags shows `latest`, `nightly`, and versioned tags (no `stable` seen on page 1).
