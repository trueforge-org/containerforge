# GitHub: JVT038/MetaTube (README facts)

Source URL(s): https://github.com/JVT038/MetaTube (fetched 2026-11-26)

## What it is
- Python/Flask web UI: downloads YouTube videos (yt-dlp) and adds metadata from MusicBrainz, Spotify, Deezer (Genius listed in to-do). FFmpeg for processing.
- Output: MP3, Opus, FLAC, WAV, OGG, M4A, MP4. Hardware encode NVENC and Intel Quick Sync tested.
- GPL-3.0. Author states project is "Finished", only bug fixes planned.
- No HTTPS/SSL, no authentication, YouTube only, SQLite only.

## Runtime requirements
- Python 3.8+, uv, git
- libmagic (apt `libmagic1`)
- FFmpeg (README lists 4.4.1)

## Env vars
| Name | Purpose | Default |
| --- | --- | --- |
| PORT | server port | 5000 |
| HOST | bind address | 127.0.0.1 (Docker sets 0.0.0.0) |
| DEBUG | debug mode | False |
| DATABASE_URL | DB URL, SQLite only | sqlite:///app.db |
| FFMPEG | folder with ffmpeg | empty |
| DOWNLOADS | download folder | `downloads` in project |
| LOG | keep logs | False |
| SOCKET_LOG | websocket logs | False |
| LOG_LEVEL | numeric log threshold | 10 |
| URL_SUBPATH | serve under subpath | / |
| INIT_DB | auto init DB and migrations | True |

Config can also be in a `.flaskenv` file (template `example.flaskenv`).

## Docker notes (README)
- Dockerfile and Dockerfile.arm64 (Raspberry Pi 4) plus docker-compose.yml
- Port 5000, PORT=5000, HOST=0.0.0.0
- Volumes: `/downloads` -> `/downloads`; database dir -> `/database`; migrations -> `/config/migrations`
- Set DATABASE_URL to a mounted path (e.g. /database), else DB resets on container update.
- Restart policy: always.
