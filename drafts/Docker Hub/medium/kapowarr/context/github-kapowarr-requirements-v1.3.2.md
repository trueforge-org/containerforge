# Upstream requirements.txt + LICENSE @ V1.3.2 (Casvt/Kapowarr)

## Source URL(s) + date
- https://raw.githubusercontent.com/Casvt/Kapowarr/V1.3.2/requirements.txt (2026-11-26)
- https://raw.githubusercontent.com/Casvt/Kapowarr/V1.3.2/LICENSE (2026-11-26; first lines only, read in a truncated fetch)
- Not fetched (same content): https://github.com/Casvt/Kapowarr/blob/HEAD/requirements.txt

## requirements.txt (V1.3.2)
| Package | Constraint |
| --- | --- |
| typing_extensions | ~= 4.12 |
| requests[socks] | ~= 2.31 |
| beautifulsoup4 | ~= 4.12 |
| flask | ~= 3.0 |
| waitress | ~= 3.0 |
| cryptography | >= 46.0.5 |
| bencoding | ~= 0.2 |
| aiohttp | ~= 3.9 |
| flask-socketio | ~= 5.3 |
| websocket-client | ~= 1.3 |
| cron-converter | ~= 1.3 |

## License
- LICENSE at V1.3.2 begins "GNU GENERAL PUBLIC LICENSE Version 3, 29 June 2007" (GPL-3.0, not AGPL).

## Install/build steps + deps
- `pip install -r requirements.txt`. No apt packages listed upstream. `cryptography` may need a wheel or build tools (not verified).

## Gotchas
- Plan.md states AGPL-3.0; fetched LICENSE text is GPL-3.0 (see README plan.md corrections).
