# Sleepingpirates/Invitarr (GitHub, redirects to faizyy01/Invitarr)

Source URL(s) + fetch date:
- https://github.com/Sleepingpirates/Invitarr (repo; redirects to https://github.com/faizyy01/Invitarr, see github-faizyy01-invitarr.md)
- https://raw.githubusercontent.com/Sleepingpirates/Invitarr/ce30f130dac51352fd5a1336c87c30cece79f085/README.md
- https://raw.githubusercontent.com/Sleepingpirates/Invitarr/ce30f130dac51352fd5a1336c87c30cece79f085/Dockerfile (same as the blob link in draft/plan)
- https://raw.githubusercontent.com/Sleepingpirates/Invitarr/ce30f130dac51352fd5a1336c87c30cece79f085/requirements.txt (same content as blob/HEAD link)
- https://raw.githubusercontent.com/Sleepingpirates/Invitarr/ce30f130dac51352fd5a1336c87c30cece79f085/LICENSE
- https://raw.githubusercontent.com/Sleepingpirates/Invitarr/ce30f130dac51352fd5a1336c87c30cece79f085/run.py
- Archive download pattern (not fetched, direct download): https://github.com/Sleepingpirates/Invitarr/archive/<sha>.tar.gz or `.zip`
- Fetched 2026-11-26

## What it is
"A chatbot that invites discord users to plex." Invites Plex users by Discord: manually with `.plexinvite <email>` or automatically when a user gets a configured role. Also removes Plex users when they leave the server or lose the role; database viewable/editable from Discord; configuration through a web portal (README, no port given).

## Install/build steps (upstream Dockerfile, verbatim)
```
FROM gorialis/discord.py
WORKDIR /app
COPY . .
RUN pip install -Ur requirements.txt
CMD ["python", "-u", "run.py"]
```
- No ARG, ENV, VOLUME, USER, EXPOSE, ENTRYPOINT. CMD runs `run.py` (README calls it `Run.py`; Dockerfile uses lowercase `run.py`).
- Base `gorialis/discord.py` (see dockerhub-gorialis-discord-py.md).

## Runtime deps
- Python (version from base image), discord.py, Plex libs.
- `requirements.txt` (verbatim):
```
discord.py
plex.py==0.9.0
PlexAPI==4.13.0
texttable
python-dotenv
```
- Only two pins. `discord.py` unpinned.

## Binaries/entrypoint/CLI flags
- Entry: `python -u run.py`.
- `run.py` (per fetch summary): imports config values from `app.bot.helper.confighelper`. Missing `switch` prints "Missing Config." and exits. Prints "V 1.0". Creates `commands.Bot(command_prefix=".", intents=intents)`, default intents with members enabled, removes default help. `on_ready` prints "bot is online.". Runs `bot.load_extension('app.bot.cogs.app')` then `bot.run(Discord_bot_token)`. `reload()` calls `bot.reload_extension` (used by `roleadd`, `setupplex`, `setuplibs`).
- `run.py` itself does not read env vars (no `os.environ`/`os.getenv`); env reading is said to be inside `confighelper` (not fetched).

## Env vars
| Name | Meaning | Source |
| --- | --- | --- |
| `token` | Discord bot token | README docker run `-e "token=..."`; read by confighelper (per plan, not fetched) |

Also `bot.env` file in the working directory with `discord_bot_token=...` per manual install instructions (README).

## Ports
None documented. README mentions a web portal but gives no port. Dockerfile has no EXPOSE.

## Volumes/paths and persistent data
- README docker run: host config dir mounted to `/app/app/config`.
- `run.py` checks `app/config/config.ini` (relative path) for `setupplex`, reads `identifier` from `BOT_SECTION` via `configparser` on `CONFIG_PATH`. Generated identifier uses `secrets.token_urlsafe(16)`.
- Config keys written via `confighelper.change_config`: `roles`, `identifier`, `plex_token`, `plex_url`, `plex_libs`.
- `config.ini` and `db.txt`: not mentioned in README (per fetch summary).

## User/UID & permissions
No USER in upstream Dockerfile (runs as root in base image). Not documented further.

## Config files and formats
- `bot.env` (Discord token), `app/config/config.ini` (INI, sections incl. `BOT_SECTION`). Config key names as above.

## Healthcheck/readiness endpoints
None.

## Discord requirements (README)
- Privileged intents must be enabled, otherwise the bot will not DM users after they receive the role. Reference: discord.py intents docs (privileged intents).
- Command prefix `.`.
- Setup commands after start: `.setupplex`, `.roleadd <@role>`, `.setuplibs` (optional, default all libraries).
- Other commands: `.plexinvite <email>`, `.plexremove <email>`, `.dbls`, `.dbadd <email> <@user>`, `.dbrm <position>`.
- Detailed Plex setup deferred to the GitHub wiki (https://github.com/Sleepingpirates/Invitarr/wiki, not fetched).

## Version/release info and asset naming
- Code reports version string `V 1.0`. No releases exist (see faizyy01 file). Pinning is by commit SHA only.

## Arch support
Not stated. Pure Python dependencies in requirements (no compiled deps listed).

## License
GPL-3.0: LICENSE at ce30f13 is GNU GPL Version 3, 29 June 2007. Header wording "only" vs "or later" not visible in fetched content. Repo page lists GPL-3.0.

## Gotchas
- Upstream README notes an inconsistency: `.dbrm` example uses `-db rm 1` style.
- The Dockerfile base is the discord.py image, which upstream maintainer says may be no longer maintained (see dockerhub-gorialis-discord-py.md).
- Archived upstream; no updates expected (see faizyy01 file).

## Contradictions with plan.md
- None found in fetched sources. Plan section 1 claims `token` is read by confighelper via `os.environ['token']`; run.py confirms config comes via confighelper, but confighelper.py itself was not fetched (UNVERIFIED).
- Plan section 1 says the run command is `Run.py` in README; README says `python3 Run.py` (capital R); Dockerfile CMD uses `run.py`. Plan uses `run.py`, which matches Dockerfile. Not a mistake.
