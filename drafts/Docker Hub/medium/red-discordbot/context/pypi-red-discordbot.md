# PyPI: Red-DiscordBot

Source URL(s):
- https://pypi.org/pypi/Red-DiscordBot/json
Fetched: 2026-11-27

## Latest
| Key | Value |
| --- | --- |
| version | 3.5.24 |
| requires_python | >=3.8.1,<3.12 |

## Pinned runtime deps (selected, latest release)
- discord-py==2.7.1, red-lavalink==0.11.1, apsw==3.46.1.0, aiohttp==3.9.5, orjson==3.10.15, pyyaml==6.0.3, psutil==7.2.2, rich==14.3.3, zstandard==0.23.0, uvloop==0.21.0 (CPython, non-win32)
- Full list in PyPI JSON `info.requires_dist`.

## Gotchas
- requires_python caps at <3.12 while the Dockerfile base is python:3.11-slim-bookworm (compatible).
- Native build deps (apsw, PyNaCl via libsodium, CFFI via libffi) are why the Dockerfile installs build-essential.
- Container pulls the latest PyPI release on each start (README), so the PyPI version may differ from the image tag.
