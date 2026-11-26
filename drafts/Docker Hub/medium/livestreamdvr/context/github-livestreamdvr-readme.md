# Upstream README + LICENSE (MrBrax/LiveStreamDVR)

## Source URL(s) + date
- https://raw.githubusercontent.com/MrBrax/LiveStreamDVR/1cd7e8fa5b68e6c0cf9e657d1caa2cc74f7eb814/README.md (2026-11-26)
- https://raw.githubusercontent.com/MrBrax/LiveStreamDVR/master/LICENSE (2026-11-26): "MIT License, Copyright (c) 2020 MrBrax".
- Not fetched: github.com/MrBrax/LiveStreamDVR repo root (covered via raw files).

## Docker (README)
- Docker Hub: https://hub.docker.com/r/mrbrax/twitchautomator (docker-compose.yml on master).
- Image is preconfigured to be hosted at `/` (does not work under a subdirectory).
- Custom base folder: set `BASE_URL` and `VITE_BASE_URL` env.
- Build locally: `docker-compose up --build -d` (needs docker-compose.yml).
- Author states they do not use Docker on their own capture setup; docker errors are hard to test.

## CLI (README)
- `--port <number>`: port to run the server on.

## Env vars (README)
| Name | Meaning |
| --- | --- |
| TCD_ENABLE_FILES_API=1 | files API (download/delete in storage); README warns of filesystem exposure |
| TCD_EXPOSE_LOGS_TO_PUBLIC=1 | log viewing in file manager; requires files API |
| TCD_MIGRATE_OLD_VOD_JSON=1 | migrate old VOD json at start; backup first |

## Gotchas
- Upstream says Docker not used by author; treat Docker setup as untested upstream.
