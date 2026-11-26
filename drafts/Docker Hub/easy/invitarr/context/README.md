# invitarr: context sources

Fetched 2026-11-26. Summaries for every web source referenced by `draft.md` and `plan.md`.

## Sources

| Source URL | File |
| --- | --- |
| https://github.com/Sleepingpirates/Invitarr (+ raw README, Dockerfile, requirements.txt, LICENSE, run.py at ce30f13; blob/HEAD requirements.txt) | github-sleepingpirates-invitarr.md |
| https://github.com/faizyy01/Invitarr (canonical; archived) and /releases | github-faizyy01-invitarr.md |
| https://hub.docker.com/r/piratify/invitarr | dockerhub-piratify-invitarr.md |
| https://github.com/trueforge-org/truecharts/tree/master/charts/stable/invitarr (Chart.yaml and values.yaml via raw) | truecharts-invitarr.md |
| https://hub.docker.com/r/gorialis/discord.py (named upstream base image, `FROM gorialis/discord.py`) | dockerhub-gorialis-discord-py.md |
| https://pypi.org/project/discord.py/ (named dependency) | pypi-discord-py.md |
| https://pypi.org/project/PlexAPI/ (named dependency) | pypi-plexapi.md |

## Skipped

| URL | Reason |
| --- | --- |
| https://cla-assistant.io/trueforge-org/containerforge | CLA page, skipped by rule |
| https://github.com/trueforge-org/containerforge/tree/main/apps/ubuntu | containerforge base link, skipped by rule |
| https://github.com/trueforge-org/containerforge/tree/main/apps/python | containerforge base link, skipped by rule |
| https://raw.githubusercontent.com/trueforge-org/forgetool/refs/heads/main/pkg/containers/test/container-test.schema.json | forgetool schema, skipped by rule |
| https://github.com/Sleepingpirates/Invitarr/archive/ce30f130dac51352fd5a1336c87c30cece79f085.tar.gz, `.zip`, and `archive/${VERSION}.tar.gz` | direct archive download. Pattern recorded in github-sleepingpirates-invitarr.md |

Named but not fetched: `plex.py` 0.9.0 (in upstream requirements.txt; plan says not imported, not checked here), Invitarr GitHub wiki (README link, not in draft/plan).

## Fetch failures

None.

## plan.md corrections

No edits made. No clear factual mistakes were found in the sources checked.

Unverified (not edited):
- plan.md section 1: "`token` read by `confighelper.py` via `os.environ['token']`". `run.py` fetched: no env reads in run.py, config comes through `app.bot.helper.confighelper`. `confighelper.py` itself was not fetched.
- plan.md sections 1 and 4 item 5: `app/bot/cogs/app.py` claims (`from discord import Webhook, AsyncWebhookAdapter`, `setup` with `bot.add_cog`, undefined `PLEX_SERVER_NAME`) and `run.py` structure. The fetched `run.py` matches the plan's description of module-level `load_extension` and `bot.run`. The cog file was not fetched.
- plan.md section 1: `plex.py==0.9.0` not imported by any file. Not checked.
- plan.md section 10: discord.py 2.7.1 on Python 3.15 and the `audioop-lts` note. The PyPI page confirms `Requires-Python >=3.8` and classifiers stop at 3.12; Python 3.15 support is not shown. Unverified.
- plan.md section 4 item 3: `patch` provided by `dpkg-dev` in base image. Not checked.
- plan.md section 1 and 10: discord.py 1.7.3 on Python 3.15 cannot run. Not checked.
- plan.md section 1: license `GPL-3.0` is consistent with LICENSE (GNU GPL v3). "only" vs "or later" wording not seen in fetched content.
- plan.md section 1: Renovate comment with `currentValue=master` and branch `master`: faizyy01 page lists default branch `master`. Consistent.
