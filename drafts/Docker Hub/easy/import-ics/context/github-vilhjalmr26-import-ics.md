# Vilhjalmr26/import_ics (GitHub)

Source URL(s) + fetch date:
- https://github.com/Vilhjalmr26/import_ics (repo)
- https://raw.githubusercontent.com/Vilhjalmr26/import_ics/ec04d6c113aa9014f2127639db9801a1fb4f9d3b/README.md
- https://raw.githubusercontent.com/Vilhjalmr26/import_ics/ec04d6c113aa9014f2127639db9801a1fb4f9d3b/dockerfile
- https://raw.githubusercontent.com/Vilhjalmr26/import_ics/ec04d6c113aa9014f2127639db9801a1fb4f9d3b/import_ics/requirements.txt (same file as the blob/HEAD link in draft/plan)
- https://raw.githubusercontent.com/Vilhjalmr26/import_ics/ec04d6c113aa9014f2127639db9801a1fb4f9d3b/import_ics/import_ics.py
- https://raw.githubusercontent.com/Vilhjalmr26/import_ics/ec04d6c113aa9014f2127639db9801a1fb4f9d3b/entrypoint.sh
- https://github.com/Vilhjalmr26/import_ics/releases (checked)
- Fetched 2026-11-26

## What it is
Cron-driven Python script that downloads `.ics` files (from URLs in a mapping file) and imports `.ics` files into a CalDAV server. It is not a web app and has no listener. Only outbound requests are made.

## Install/build steps and build deps (from upstream dockerfile at ec04d6c)
- Base: `FROM python:3.9.13-alpine3.16`
- `RUN apk update && apk add tzdata`
- `COPY ./import_ics /import_ics`; `WORKDIR import_ics`
- `RUN mkdir ical_export`; `RUN mkdir samples`; `RUN mv calendar_download_map.py samples/calendar_download_map.py`
- `RUN mkdir /config`; `RUN ln -s /config/calendar_download_map.py calendar_download_map.py`
- `RUN pip install -r requirements.txt`
- `COPY ./import_ics.sh /import_ics.sh` and `COPY ./entrypoint.sh /entrypoint.sh`, both `chmod 500`
- `ENTRYPOINT /entrypoint.sh`; no CMD, no ARG, no VOLUME, no USER, no EXPOSE
- Note: upstream `COPY ./import_ics.sh` refers to a file not shown in the repo listing we fetched; the runner script is `/import_ics.sh` (its contents were not fetched).

## Runtime deps
- Python (3.9 in upstream image), cron daemon (`crond`), tzdata.
- Python packages: `requirements.txt` at ec04d6c is a single line: `caldav` (unpinned).
- Code imports `caldav`, `pprint`, `os`, `requests`, `calendar_download_map`. `requests` is imported but not listed in requirements.txt.

## Binaries/entrypoint/CLI flags
- Script shebang: `#!/usr/local/bin/python`. Entry: `if __name__=="__main__":` creates `Import_ICS()`, calls `create_new()`, then `import_ics()`.
- Upstream `entrypoint.sh` (verbatim logic):
  - if `/config/calendar_download_map.py` missing: `cp /import_ics/samples/calendar_download_map.py /config/calendar_download_map.py` and `chmod 777` it
  - `cd /import_ics`
  - `echo "${CRONTAB_SCHEDULE} /import_ics.sh" > crontab`
  - `chown root:root /ical_export`
  - `crontab crontab`
  - `crond -f` (foreground cron daemon)
- No explicit exit codes, no logging module, no error handling. Output is only `pprint.pprint(filenames)` and `print("creating: " + tar_cal)`.

## Env vars
| Name | Upstream default | Read by | Meaning |
| --- | --- | --- | --- |
| `ICS_URL` | `https://example.com/dav.php` (Dockerfile ENV placeholder) | `import_ics.py` via `os.getenv` (no default in code, None if unset) | CalDAV server URL |
| `ICS_USERNAME` | `username` (placeholder) | `import_ics.py` via `os.getenv` | CalDAV username |
| `ICS_PASSWORD` | `password` (placeholder) | `import_ics.py` via `os.getenv` | CalDAV password |
| `CRONTAB_SCHEDULE` | `0 0 * * *` | `entrypoint.sh` | cron schedule string |
| `TZ` | `UTC` (Dockerfile ENV); README example `America/Chicago` | system / cron | timezone |

## Ports
None. No ports in code, Dockerfile, or README.

## Volumes/paths and persistent data
- README: config path is `/config`. `calendar_download_map.py` lives in `/config` (dict `mapping = {"calendar name": "https://...ics"}`; downloaded at each run).
- README: `/config/ical_export` holds manual `.ics` files named `calendar_name.ics`, imported on each run.
- Code paths are relative to working dir: `./ical_export/` (read by `get_target_calendars` which only counts entries ending `.ics`; written by `download_calendars` with `"wb"`). The script never creates `./ical_export`, so it must already exist.
- Upstream Dockerfile symlinks `/import_ics/calendar_download_map.py` -> `/config/calendar_download_map.py`.
- Download happens at object construction: `__init__` -> `get_target_calendars` -> `download_calendars`.

## User/UID & permissions
- Upstream runs as root (cron as root, `chown root:root /ical_export`). No USER declared.

## Config files and formats
- `calendar_download_map.py`: Python module with `mapping` dict (calendar name -> ICS URL).
- `ical_export/<calendar>.ics`: ICS files. Parser is hand-written line-based: `BEGIN:VEVENT` switches header->events mode, `METHOD` header lines dropped, `END:VEVENT` appends event, `END:VCALENDAR` skipped.

## CalDAV usage (2022-era code)
- `caldav.DAVClient(url=..., username=..., password=...)` used as context manager in `get_calendar_names`, `import_ics`, `create_new`.
- `client.principal()`, `my_principal.calendars()` (reads `cal.name`), `my_principal.make_calendar(name=...)` for missing calendars, `cal.save_event(ical=temp_event)` per event.

## Healthcheck/readiness endpoints
None. No HTTP endpoint.

## Version/release info and asset naming
- GitHub releases page: "There aren't any releases here." No tags shown. No release assets.
- Only pinning method is a commit SHA. Download form: `https://github.com/Vilhjalmr26/import_ics/archive/<sha>.tar.gz` (or `.zip`); no checksum published.
- Pinned commit referenced in draft/plan: `ec04d6c113aa9014f2127639db9801a1fb4f9d3b` (full SHA confirmed by raw fetch; raw URLs with the full SHA return content).
- Docker Hub `vilhjalmr26/import_ics` only has `latest` tag (see dockerhub file).

## Arch support
Pure Python, no compiled code in upstream. Upstream Dockerfile base is alpine (`python:3.9.13-alpine3.16`); arch not stated in repo.

## License
- `LICENSE` at ec04d6c: HTTP 404 (not found). Also tried `main` branch raw LICENSE: HTTP 404. README does not name a license. No license in repo.

## Gotchas
- `requirements.txt` only lists `caldav`; `requests` is needed by code but not declared (plan already notes this).
- `calendar_download_map.py` is read at import time; the script downloads on construction.
- Upstream sets env defaults to placeholders (`example.com`, `username`, `password`); the TrueCharts chart uses empty `ICS_URL`/`ICS_USERNAME` and a secret for `ICS_PASSWORD`.
- Repo last commit (plan) 2022-06-08; not re-verified here.
- The `import_ics.py` file contains a leftover comment `#, url, username, password, calendars = []` in `__init__`.

## Contradictions with plan.md
- Plan section 1 says `TZ` default should be `Etc/UTC`; upstream sets `TZ="UTC"` (plan's own choice in section 6 is a design choice, not a contradiction of upstream).
- Plan section 4 step 4 assumes `import_ics/` contents are copied to `/app/import_ics`; upstream layout matches (`import_ics/` dir with `import_ics.py` and `calendar_download_map.py`). No contradiction.
- Plan section 10: "UNVERIFIED that the script works with caldav 3.x (DAVClient context manager, principal().calendars(), save_event(ical=...))". See pypi-caldav.md: current caldav docs name `get_davclient()` and `principal.get_calendars()`; `DAVClient` and `save_event` are not named on the PyPI page. Still unverified.
