# DiscordGSM/GameServerMonitor requirements.txt

Source URL(s) + fetch date:
- https://raw.githubusercontent.com/DiscordGSM/GameServerMonitor/2.20.1/requirements.txt (tag 2.20.1, used for the pin list) · 2026-11-26
- https://github.com/DiscordGSM/GameServerMonitor/blob/HEAD/requirements.txt (HEAD, fetched as raw HEAD; NEWER than the tag, do not use for pins) · 2026-11-26

## Tag 2.20.1 (authoritative for this container)
- aiohttp==3.13.3
- audioop-lts==0.2.2; python_version>="3.13"
- discord.py==2.6.4
- flask[async]==3.1.2
- gunicorn==23.0.0
- opengsq==3.6.0
- psycopg2-binary==2.9.11
- pymongo==4.15.5
- python-dotenv==1.2.1
- pywin32==311; platform_system=="Windows"
- typing-extensions==4.15.0
- tzdata==2025.3

Two lines have environment markers: `audioop-lts` (Python >= 3.13) and `pywin32` (Windows only).

## HEAD (newer, not used)
- aiohttp==3.13.5, audioop-lts==0.2.2 (python >= 3.13), discord.py==2.7.1, flask[async]==3.1.3, gunicorn==26.0.0, opengsq==3.6.2, psycopg2-binary==2.9.12, pymongo==4.17.0, python-dotenv==1.2.2, pywin32==311 (Windows), typing-extensions==4.15.0, tzdata==2026.2.

## Gotchas
- Pins in plan.md section 1 match the tag exactly.
