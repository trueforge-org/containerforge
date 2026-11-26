# context: discordgsm

## Sources (URL -> file)
| Source URL | File | Fetched |
| --- | --- | --- |
| https://github.com/DiscordGSM/GameServerMonitor (README via raw HEAD) | github-discordgsm-gameservermonitor.md | 2026-11-26 |
| https://github.com/DiscordGSM/GameServerMonitor/releases/tag/2.20.1 | github-discordgsm-gameservermonitor.md | 2026-11-26 |
| https://github.com/DiscordGSM/GameServerMonitor/blob/17d2e124a3d7a4b4cc4b64bada325f363fb162da/Dockerfile | github-discordgsm-gameservermonitor-dockerfile.md | 2026-11-26 |
| https://github.com/DiscordGSM/GameServerMonitor/blob/HEAD/requirements.txt | github-discordgsm-gameservermonitor-requirements.md (HEAD; newer than tag) | 2026-11-26 |
| https://raw.githubusercontent.com/DiscordGSM/GameServerMonitor/2.20.1/requirements.txt (followed to match tag) | github-discordgsm-gameservermonitor-requirements.md | 2026-11-26 |
| https://discordgsm.com | docs-discordgsm-com.md | 2026-11-26 |
| https://discordgsm.com/guide/how-to-get-a-discord-bot-token | docs-discordgsm-com-guide-bot-token.md | 2026-11-26 |
| https://hub.docker.com/r/discordgsm/discord-game-server-monitor | dockerhub-discordgsm-discord-game-server-monitor.md | 2026-11-26 |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/discordgsm (read via raw values.yaml) | truecharts-discordgsm.md | 2026-11-26 |

## Skipped
- https://cla-assistant.io/trueforge-org/containerforge: CLA link.
- https://raw.githubusercontent.com/trueforge-org/forgetool/... (both schema URLs): forgetool schema.
- https://github.com/trueforge-org/containerforge/tree/main/apps/python and .../apps/ubuntu: containerforge base app links.
- https://github.com/DiscordGSM/GameServerMonitor/archive/refs/tags/${VERSION}.tar.gz and .../archive/refs/tags/2.20.1.tar.gz: direct archive download.
- https://github.com/DiscordGSM/GameServerMonitor/archive: template with variable.

## Not fetched (could not be verified)
- https://discordgsm.com/guide (linked as `/guide#installation`, not in draft/plan as a URL): not fetched in this pass.

## Fetch failures
- https://discordgsm.com and https://discordgsm.com/guide/how-to-get-a-discord-bot-token returned only page titles (no body text).
- releases/tag/2.20.1: asset list did not load. No asset names or digests.

## plan.md corrections
- Section 1, "Upstream Dockerfile" row: plan said upstream user is `dgsm`. The fetched Dockerfile (commit 17d2e12) has no `USER` line, so it runs as root. Changed to: "no `USER` (runs as root)". Source: github-discordgsm-gameservermonitor-dockerfile.md.
- Unverified (left as-is): plan.md says the upstream Dockerfile runs `mkdir /usr/src/app/data`. The fetched Dockerfile's RUN steps show only `pip install --upgrade pip` and `pip install --no-cache-dir -r requirements.txt`.
- Unverified: plan.md's `LICENSE` = MIT (README does not name the license).
- Confirmed (no edit): `2.20.1` tag, `python:3.13-alpine`, tag-pinned requirements (aiohttp 3.13.3, discord.py 2.6.4, etc.), chart image digest, `/app/data` persistence, chart postgres dependency optional.
- Note: the raw HEAD requirements file is newer than the tag (aiohttp 3.13.5, discord.py 2.7.1...). Plan correctly uses the tag.
