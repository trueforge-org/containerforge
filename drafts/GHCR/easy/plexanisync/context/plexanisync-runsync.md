# RickDB PlexAniSync run/runsync.sh (v1.4.4)

## Source URL(s) + date
- https://raw.githubusercontent.com/RickDB/PlexAniSync/v1.4.4/Docker/PlexAniSync/run/runsync.sh (fetched 2026-11-27)
- Equivalent API URL in plan (contents/...?ref=v1.4.4) not fetched; raw used instead (same file)

## What it is
Container entrypoint loop (CMD). Runs the sync repeatedly.

## Logic
- `run()`: loop { `python PlexAniSync.py`; if `INTERVAL` > 0 then `sleep ${INTERVAL}`, else echo "Sync was completed and INTERVAL <= 0, quitting" and break }
- Main: if `SETTINGS_FILE` is empty, `echo "Updating settings.ini"`, `python settingsupdater.py`, then `run`
- If `SETTINGS_FILE` is set: `echo "Using custom config: $SETTINGS_FILE"`, then `run` (no settings generation)

## Entrypoint/flags
- Command: `/plexanisync/runsync.sh` (no args). Python scripts resolved relative to cwd (/plexanisync)

## Env vars used
| Name | Effect |
| --- | --- |
| SETTINGS_FILE | if set, skip settingsupdater and use that ini file |
| INTERVAL | seconds between syncs; <= 0 exits after first sync |

## Gotchas
- With SETTINGS_FILE unset, settingsupdater.py rewrites /plexanisync/settings.ini on every start (see `plexanisync-settingsupdater.md`). The chart mounts that path read-only (see `truecharts-plexanisync.md`), so a custom settings file via SETTINGS_FILE is needed for that mount to work.
- Exit path: when INTERVAL <= 0 the container stops after one sync.
