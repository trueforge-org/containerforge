# invitarr — implementation plan
> Source: ./draft.md · Target: apps/invitarr/ · Difficulty: medium (draft says easy; the code targets discord.py 1.x and needs patching) · Role: main · Verified on 2026-11-23

## 1. Verified upstream facts

| Item | Value |
| --- | --- |
| Project state | `Sleepingpirates/Invitarr` now redirects to `faizyy01/Invitarr`, which is **archived (read-only since 2025-09-03)**. No releases (`/releases/latest` redirects to the empty list). Reported version string in code: `V 1.0`. |
| Version to pin | Commit `ce30f130dac51352fd5a1336c87c30cece79f085` (draft's Dockerfile link). UNVERIFIED that it is the head of the archived default branch; the faizyy01 repo's own Dockerfile differs (python 3.6-slim plus nginx, a newer web-portal layout). |
| Renovate | `// renovate: datasource=git-refs depName=https://github.com/Sleepingpirates/Invitarr currentValue=main` (default branch name UNVERIFIED; check before use). Realistically no updates will ever come. |
| License | GPL-3.0 (LICENSE file is GPLv3; GitHub reports SPDX `GPL-3.0` for the faizyy01 repo). Use `GPL-3.0` and verify "only" or "or-later" wording in file headers (none seen). |
| Source URL | https://github.com/Sleepingpirates/Invitarr (draft); canonical now https://github.com/faizyy01/Invitarr |
| Download | `https://github.com/Sleepingpirates/Invitarr/archive/ce30f130dac51352fd5a1336c87c30cece79f085.tar.gz`. No checksum; commit SHA pins content. |
| Upstream Dockerfile reviewed | `FROM gorialis/discord.py`, `WORKDIR /app`, `COPY . .`, `pip install -Ur requirements.txt`, `CMD ["python","-u","run.py"]`. README docker run: `-v <path>:/app/app/config -e token=<discord token>`. |
| `requirements.txt` | `discord.py`, `plex.py==0.9.0`, `PlexAPI==4.13.0`, `texttable`, `python-dotenv` (all unpinned except two). PyPI latest: discord.py 2.7.1, PlexAPI 4.18.3, plex.py 0.9.0. |
| Real env vars | `token` (Discord bot token; read by `confighelper.py` via `os.environ['token']`); `bot.env` file with `discord_bot_token` also supported. Other settings (Plex token and URL, roles, libraries, channel) are stored by bot commands in `app/config/config.ini` (relative path). Database file path is relative too (`app/config/...`, plus `db.txt` in cwd). |
| Ports | None. The bot only makes outbound connections to Discord and Plex. (The README mentions a web portal, but that exists only in the later faizyy01 layout, not at this commit.) |

## 2. Target layout

```
apps/invitarr/
  Dockerfile
  docker-bake.hcl
  settings.yaml
  container-test.yaml
  start.sh
  scripts/invitarr-compat.patch    # discord.py 2.x compatibility patch (see section 4)
```

`scripts/` is allow-listed by `include/.dockerignore`; since a build-time RUN needs the patch before the final `COPY . /`, add an early `COPY scripts/invitarr-compat.patch /tmp/` in the Dockerfile. No `defaults/`, no `root/`, no `DOWNSTREAM_CHANGES.md`.

## 3. Base image

`FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d`

Why: Python bot, pure-Python deps (draft agrees). Closest sibling: `apps/changedetection` and `apps/bazarr`. Python rules apply: `/app/venv` read-only at runtime, caches in `/tmp`.

## 4. Dockerfile

1. `FROM` above, `ARG VERSION`, `USER root`, `ENV PYTHONUNBUFFERED=1 PYTHONPATH=/app/invitarr`.
2. `COPY scripts/invitarr-compat.patch /tmp/invitarr-compat.patch`.
3. RUN: `mkdir -p /app/invitarr`; `curl -fsSL https://github.com/Sleepingpirates/Invitarr/archive/${VERSION}.tar.gz | tar xz -C /app/invitarr --strip-components=1`; `cd /app/invitarr && patch -p1 < /tmp/invitarr-compat.patch` (apt package `patch` only if the base lacks it; check first, pin the apt version if it must be installed); `/app/venv/bin/pip install --no-cache-dir "discord.py==2.7.1" "plex.py==0.9.0" "PlexAPI==4.18.3" texttable python-dotenv` (replace the unpinned `requirements.txt` by explicit pins decided at implementation; PlexAPI 4.13.0 as upstream pinned is also acceptable, test both); `chown -R apps:apps /app && chmod -R 755 /app`; `rm -rf /tmp/*`.
4. Licenses: `cp /app/invitarr/LICENSE /usr/share/licenses/invitarr/LICENSE`.
5. **The compatibility patch is required**, because the code only works on discord.py 1.x (`from discord import Webhook, AsyncWebhookAdapter` in `app/bot/cogs/app.py` raises ImportError on 2.x; `def setup(bot): bot.add_cog(...)` and `bot.load_extension(...)` at module level are synchronous in `run.py`). discord.py 1.7.3 itself does not run on Python 3.15 (old aiohttp pin), so staying on 1.x is not possible. Minimal patch to write at implementation:
   - `app.py`: drop `AsyncWebhookAdapter`, build webhooks with `discord.Webhook.from_url(url, session=...)`; make `setup` async and `await bot.add_cog(...)`.
   - `run.py`: replace the last lines with an `async def main()` that does `async with bot: await bot.load_extension('app.bot.cogs.app'); await bot.start(token)` and `asyncio.run(main())`; make `reload()` await `reload_extension`.
   - Add `intents.message_content = True` (required for `.`-prefixed commands on 2.x; also enable the Message Content and Members intents in the Discord developer portal).
   Any further breakage found at runtime is fixed in the same patch. This is the main effort of the port; keep the patch small and documented.
6. `USER apps`, `COPY --chmod=0755 . /`, `VOLUME /config`, `WORKDIR /config`. No `EXPOSE`.

## 5. docker-bake.hcl

- `APP` = `invitarr`
- `VERSION`: git-refs renovate comment above, `default = "ce30f130dac51352fd5a1336c87c30cece79f085"`
- `LICENSE` = `GPL-3.0`
- `SOURCE` = `https://github.com/faizyy01/Invitarr` (canonical, archived; `settings.yaml` `upstream_env_url` must equal it). The draft URL redirects here; the download URL in the Dockerfile may keep the old name (GitHub redirects) or be switched, decide at implementation and keep SOURCE consistent.
- Standard four targets plus default group (copy `apps/bazarr/docker-bake.hcl`). Validate with `docker buildx bake --print`.

## 6. settings.yaml

Header, `schema_version: 1`, `upstream_env_url` = SOURCE.

- ports: none (`ports: []`).
- env: `token` (name exactly as the app reads it, lower-case) default `""` required false; `TZ` default `"Etc/UTC"` required false. Do not list other variables: Plex and role settings are stored through Discord commands, not env.
- volumes: `/config` required true (config.ini, database, `db.txt`).
- dependencies: none in ContainerForge. Needs an external Discord bot token and a Plex server (UNVERIFIED whether `apps/plex` exists; check and mark as optional dependency, not a hard one).

`required: false` for `token` because the container must start without it (see `start.sh`).

## 7. start.sh

`#!/usr/bin/env bash`, `set -euo pipefail`.

1. `cd /config && mkdir -p app/config` (the app uses cwd-relative `app/config/config.ini`; with cwd `/config` the state lands in `/config/app/config` while the code stays in `/app/invitarr`, found via `PYTHONPATH`). Idempotent.
2. If `token` is empty and neither `/config/bot.env` nor an existing `app/config/config.ini` has a token: log `No Discord token set (env "token" or /config/bot.env); idling.` and `exec sleep infinity`. Upstream would print "Missing Config." and exit; idling avoids a crash loop and lets the test harness pass.
3. Do not write the token to disk or arguments; the app reads `os.environ['token']`.
4. `exec /app/venv/bin/python -u /app/invitarr/run.py`.

Nothing writes to `/app`. `db.txt` and `bot.env` are cwd-relative, so they land in `/config`.

## 8. container-test.yaml

No ports, so no tcp/http probes.

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json

timeoutSeconds: 120
filePaths:
- /app/invitarr/run.py
- /app/invitarr/app/bot/cogs/app.py
healthCommands:
- command: /app/venv/bin/python -c "import discord, plexapi, texttable, dotenv; import app.bot.cogs.app"
```

The last command proves the patched cog imports on discord.py 2.x (run with `PYTHONPATH=/app/invitarr` set in the image ENV). The online part (bot logs in, `bot is online.`) needs a real token and cannot run in the harness (no env): run it by hand per the protocol.

## 9. Rootless and read-only-rootfs adaptations

| Upstream write | Remap |
| --- | --- |
| `/app/app/config/config.ini` (chart pvc `/app/app/config`) | cwd `/config`, so `/config/app/config/config.ini` |
| `bot.env`, `db.txt` in cwd | `/config` |
| pip install at build as root | build time into `/app/venv` |

Chart runs UID 0; here UID 568 with read-only rootfs and `/tmp` tmpfs. The draft's extra persistence `/app/app/config` moves under `/config` (existing data must be moved to `<volume>/app/config`; document). No capabilities.

## 10. Risks, caveats and open questions

- **Archived upstream** and written for discord.py 1.x: porting needs the compatibility patch, which makes this more than "easy". Decide whether a patched, unmaintained bot is worth shipping; alternative is to skip it.
- Needs a Discord application with the Members, and (on 2.x) Message Content privileged intents enabled (README warns about intents).
- Needs a Plex server and Plex OAuth via Discord DMs (outside the container).
- `plex.py==0.9.0` is old and unmaintained; UNVERIFIED that it installs cleanly on Python 3.15 (it may pull legacy deps). If it fails, check whether the code really imports it (`from plexapi...` is used; `plex.py` may be unnecessary and can be dropped after a grep at implementation).
- Draft caveat on the state path is confirmed and solved with cwd `/config`.
- UNVERIFIED: default branch name and whether the commit is head; license "only/or-later".
- No GPU, privileged or musl issue; arm64 fine (pure Python).

## 11. Build and test steps

```sh
cd apps/invitarr
docker buildx bake --print
docker buildx bake --set image-local.platform=linux/amd64 image-local
docker volume create invitarr-probe-config
docker run --rm -d --name invitarr-probe --read-only --tmpfs /tmp \
  -v invitarr-probe-config:/config invitarr:ce30f130dac51352fd5a1336c87c30cece79f085
docker logs -f invitarr-probe
```

Readiness without a token: the idle log line, process alive. With a real test token (`-e token=...`, throw-away bot in a private Discord server): logs show `V 1.0` and `bot is online.` and no traceback; run `.plexinvite` style commands only against a test Plex. Then `forgetool containers test --image invitarr:<sha> --config ./apps/invitarr/container-test.yaml`; clean up.

## 12. PR checklist

- Branch `feat/add-invitarr`, commit and PR title `feat(invitarr): add new container`, target `main`.
- Fill `.github/PULL_REQUEST_TEMPLATE.md`; tick only applicable boxes.
- Notes: `🤖 This PR is AI generated.`; explain the patch and the archived upstream.
- CLA notice: https://cla-assistant.io/trueforge-org/containerforge (only the user can sign).
- Untested to state: bot login against Discord, Plex flows, arm64, patch coverage of every cog path.
