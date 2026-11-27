# Docker Hub: phasecorex/red-discordbot

Source URL(s):
- https://hub.docker.com/v2/repositories/phasecorex/red-discordbot/
- https://hub.docker.com/v2/repositories/phasecorex/red-discordbot/tags?page_size=10
Fetched: 2026-11-27

## Repository
| Key | Value |
| --- | --- |
| description | The newest Red-Discordbot in a convenient multi-arch container |
| pull_count | 14425200 |
| star_count | 24 |
| last_updated | 2026-11-24 |
| tag count | 31 |
| platforms | multi-arch index (amd64, arm64, arm/v7) |

## Tags (page_size=10, first page)
| Tag | Arch | Last pushed |
| --- | --- | --- |
| latest (index) | amd64, arm64, arm/v7 | 2026-11-24 |
| extra-pylav (index) | amd64, arm64, arm/v7 | 2026-11-24 |
| full-pylav | index | not captured |
| latest-pylav, core-pylav, pylav | index | not captured |
| core-audio, core-audio-py311, audio, audio-py311 | index | not captured |

- Tag `full` (chart pin) is not on the first page; not verified (31 tags total, pages 2-4 not fetched).

## Run (README, PhasecoreX/docker-red-discordbot)
- `docker run -v /local/folder/for/persistence:/data -e TOKEN=bot_token -e PREFIX=. phasecorex/red-discordbot`
- Persistent volume: `/data`.
- Env: TOKEN, PREFIX (PREFIX2-PREFIX5), OWNER are one-time settings saved to bot config; TZ (default UTC); PUID/PGID (default 1000).
- Image runs non-root; Red installs cogs in venv at `/data/venv`.
- Redbot-setup CLI: `docker run -it --rm -v <dir>:/data phasecorex/red-discordbot redbot-setup ...`.
- RPC port listens on localhost only; host networking needed for host-side access (README).

## Gotchas
- Image variants are selected by tag (core, extra, core-audio, extra-audio, core-pylav, extra-pylav, plus `latest`/`full`-style tags).
