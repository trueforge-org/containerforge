# Docker Hub: krateng/maloja

Source URL(s), fetched 2026-11-27:
- https://hub.docker.com/v2/repositories/krateng/maloja/
- https://hub.docker.com/v2/repositories/krateng/maloja/tags?page_size=10

## Repository
- Namespace/owner `krateng`, name `maloja`, public, active
- Description: "Self-hosted music scrobble database to create personal listening statistics and charts"
- Pull count 1,375,515; stars 13
- Last updated 2026-11-26

## Project state (repo description)
- Security updates only. Author is building a successor, maloja-rs. Current version still works.
- No social, radio or recommendation features.

## Tags (page 1 of 44)
| Tag | Last updated | Full size | Arch / os |
| --- | --- | --- | --- |
| latest | 2026-11-26 | 48278652 | amd64, arm64 (linux) |
| 3.2.11 | 2026-11-26 | 48278652 | amd64, arm64 (linux) |
| 3.2.10 | 2026-11-06 | 48346571 | amd64, arm64 (linux) |
| 3.2.9 | 2026-10-16 | 48214675 | amd64, arm64 (linux) |
| 3.2.8 | 2026-10-16 | 48214870 | amd64, arm64 (linux) |
| 3.2.7 | 2026-10-09 | 48213890 | amd64, arm64 (linux) |
| 3.2.6 | 2026-08-13 | 48162644 | amd64, arm64 (linux) |
| 3.2.5 | 2026-08-10 | 48132238 | amd64, arm64 (linux) + 2 unknown attestation entries |
| 3.2.4 | 2025-02-10 | 47400345 | amd64, arm64 (linux) + 2 unknown entries |
| 3.2.3 | 2025-01-15 | 52536512 | amd64, arm64 (linux) + 2 unknown entries |

- Per-arch sizes for 3.2.10: amd64 48346571, arm64 49113504.

## Config (repo description)
- Required env: `MALOJA_SKIP_SETUP` (non-interactive; set in Containerfile), `MALOJA_DATA_DIRECTORY` (container path for config and data), `MALOJA_FORCE_PASSWORD` (admin password, first run only).
- `PUID` / `PGID`: for Docker on Linux, set to host folder owner IDs; not needed with rootless Podman.
- Any setting can be given as `MALOJA_`-prefixed env var.
- Default port 42010 (must be published). IPv4 by default.
- Volume: mount host dir to the data directory path, e.g. `-v $PWD/malojadata:/mljdata`.
- Minimal run: `docker run -p 42010:42010 -v $PWD/malojadata:/mljdata -e MALOJA_DATA_DIRECTORY=/mljdata krateng/maloja`
- Non-container config paths: `/etc/maloja/settings.ini`, rules `/etc/maloja/rules` (`rules.info`), images `/var/lib/maloja/images` (`images.info`).
- Import folder lives in the data directory. Supported imports: Last.fm, Spotify, ListenBrainz, another Maloja export.
- Image display needs free Last.fm and Spotify API keys. Reverse proxy recommended for SSL.
- Web pages: /admin_setup, /admin_manual, /api_explorer.

## Gotchas
- Upstream is in maintenance mode (security only); successor maloja-rs is in progress.
- Docker Hub `latest` = 3.2.11 (same digest content as 3.2.11). Repo's Containerfile in this summary is for 3.2.10.
