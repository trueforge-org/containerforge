# jo-nike/clipplex README

Source: https://raw.githubusercontent.com/jo-nike/clipplex/master/README.md (fetched 2026-11-26)

## What it is
- Pulls clips out of movies/shows on a Plex server to share; Flask web frontend (SB Admin UI)
- Optional Streamable integration (login creds)
- Version 0.0.3 (initial release); license MIT

## Install/run
- `docker run -d --name clipplex -p 9945:5000 -v /media:/media -v /volumes/clipplex:/app/app/static/media --restart always -e PUID=1000 -e PGID=1000 -e TZ=America/New_York -e PLEX_URL=... -e PLEX_TOKEN=... jonnike/clipplex:latest`
- Compose: image jonnike/clipplex:latest; env PYTHONUNBUFFERED=1, PUID, PGID, TZ, PLEX_URL (e.g. http://plex:32400), PLEX_TOKEN, STREAMABLE_LOGIN, STREAMABLE_PASSWORD; same two volumes; ports 9945:5000 (README compose sample malformed)

## Env vars
| Var | Req | Note |
| --- | --- | --- |
| PUID / PGID | opt | 1000 example (README table says GUID; commands use PGID) |
| TZ | opt | America/New_York example |
| PLEX_URL | yes | Plex address |
| PLEX_TOKEN | yes | Plex token |
| STREAMABLE_LOGIN / STREAMABLE_PASSWORD | opt | |

## Ports
- 5000 container (UI); examples map host 9945

## Volumes
- /media: media, same absolute paths Plex uses
- /app/app/static/media: clip output

## Network
- Container must reach Plex

## Config files
- none (env only)

## Gotchas
- Plex paths must match inside container
