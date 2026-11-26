# hub.docker.com/r/jkirkcaldy/plex-utills

Source URL(s) + fetch date:
- https://hub.docker.com/r/jkirkcaldy/plex-utills
- Fetched 2026-11-26

## What it is
- Image `jkirkcaldy/plex-utills`, publisher jkirkcaldy. Short description: "Manage your plex library with some python scripts." Runs as a browser UI.
- 100K+ pulls, rating 4 (page-reported).

## Run example (no compose file on the page)
```
docker run -d -p 5000:5000 -v <your/plex/media>:/films -v <mount/your/logs>:/logs -e TZ=Europe/london -e PUID=1000 -e PGUI=1000 jkirkcaldy/plex-utills
```
- Port 5000 serves the web UI.
- `/films` = Plex media; `/logs` = logs; extra `/config` mount for migrating an old config.
- Env vars shown: TZ, PUID, PGUI (page spelling, probably a typo for PGID).

## Tags and arch
- Only tag shown: `latest` (digest sha256:33ca56a98..., 468.9 MB).
- Supported architectures: not stated.

## Version/release info
- Page says "about 3 years ago" / "almost 4 years ago" for last update; no exact date.

## Gotchas
- Page says the project runs entirely through a browser interface.
- Conflicts with the wiki (`-p 80:80`) and with the Dockerfile's `EXPOSE 80 5000` on the UI port; see github-jkirkcaldy-plex-utills.md.
