# DiscordGSM/GameServerMonitor (repository, README, release 2.20.1)

Source URL(s) + fetch date:
- https://github.com/DiscordGSM/GameServerMonitor (README via raw HEAD) · 2026-11-26
- https://github.com/DiscordGSM/GameServerMonitor/releases/tag/2.20.1 · 2026-11-26

## What it is
A Discord bot that tracks live data of game servers and can alert when a server goes down. Interaction is through Discord slash commands. Python app.

## Install options (from README)
- Hosted public bot (limited to 10 monitored servers per Discord guild).
- Self-hosting: README points to https://discordgsm.com/guide#installation (no steps in README).
- Docker Hub image referenced (`discordgsm/discord-game-server-monitor`), a Docker build workflow exists. No run commands in README.
- Pip/python package CI badge only. No pip instructions.

## Build/runtime (from Dockerfile, see github-discordgsm-gameservermonitor-dockerfile.md)
- Upstream: `python:3.13-alpine`, `pip install --no-cache-dir -r requirements.txt`, `CMD ["python", "main.py"]`.

## Python dependencies
- Pinned in `requirements.txt` at tag 2.20.1: see github-discordgsm-gameservermonitor-requirements.md.

## Env vars and config
- README does not list env vars. From plan.md / source files (not fetched in this pass): see plan.md section 1. Env vars confirmed only by the chart's `gsm` block (see truecharts-discordgsm.md), which shows `app_token`, `whitelist_guilds`, `app_activity_type`, `app_activity_name`, `app_presence_advertise`, `task_query_server`, `command_query_public`, `command_query_cooldown`, `web_api_enable`, `postgres_ssl_mode`, `factorio_username`, `factorio_auth_token`, `workers`, `timeout`.

## Ports / web UI
- README does not state ports. Chart runs `gunicorn` with the `gthread` worker class on `0.0.0.0:<port>` for `app:app` in the background, then `python -u main.py`. Web UI/API is optional and off by default (`web_api_enable: false` in chart).

## Data/log paths
- Not stated in README. Chart mounts persistence at `/app/data`.

## Platforms / supported games
- Discord platform. Supported games list at https://discordgsm.com/guide/supported-games (not fetched). Translations in `/discordgsm/translations/<locale>.json` in repo.

## Version/release info
- Release `2.20.1` (marked Latest) published 09 Jan 2026 by BattlefieldDuck, commit `17d2e12`. 39 commits on main since.
- Changes: Exfil game support, BattleMetrics fallback for ASA, pytest 8.4.2 -> 9.0.2, aiohttp 3.13.2 -> 3.13.3.
- Release page says "Assets 2" but the asset list did not load. No asset names or digests obtained. Plan.md says source tarball `archive/refs/tags/2.20.1.tar.gz` (not fetched; direct archive, skipped).

## License
- A license badge links to the LICENSE file; the type is not named in README. Plan.md says MIT (not confirmed by this fetch).

## Gotchas
- Upstream Dockerfile and requirements are consistent with plan.md.
- The raw README comes from HEAD, not the tag.
