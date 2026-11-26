# github.com/jkirkcaldy/plex-utills

Source URL(s) + fetch date:
- https://github.com/jkirkcaldy/plex-utills (repo root, via raw README)
- https://raw.githubusercontent.com/jkirkcaldy/plex-utills/master/README.md
- https://raw.githubusercontent.com/jkirkcaldy/plex-utills/master/Dockerfile
- https://raw.githubusercontent.com/jkirkcaldy/plex-utills/master/requirements.txt
- https://github.com/jkirkcaldy/plex-utills/releases
- https://github.com/jkirkcaldy/plex-utills/releases/tag/0.21.12 (via releases list)
- https://github.com/jkirkcaldy/plex-utills/wiki (home), followed: wiki/Installation, wiki/Config-Settings
- Fetched 2026-11-26

## What it is
- Docker-only tool with a browser UI that manages Plex libraries (4K/HDR/3D poster banners, "Hide 4K" tag, Disney/Pixar collections, library search with TMDB poster upload, migration of old config files and old HDR banners).
- Works best with TheMovieDB as the Plex metadata agent. TMDB API key is optional (needed for poster search/upload).
- Version noted in README: 23.01.31. Upstream is dormant (last wiki edit 2023-02-01).

## Install/build steps and build deps (upstream Dockerfile, master)
- `FROM python:3.9.16-slim-bullseye`
- `ARG TZ=Europe/London`, `ENV TZ="${TZ}"`
- `apt update && apt upgrade -y && apt install -y wget git`
- `wget https://mediaarea.net/repo/deb/repo-mediaarea_1.0-21_all.deb`, `dpkg -i` it (MediaArea apt repo)
- apt install: `mediainfo nginx ffmpeg libsm6 libxext6 nano`, then `rm /var/lib/apt/lists/*`
- Copies `app/static/dockerfiles/default` to `/etc/nginx/sites-enabled/default` (nginx reverse proxy config)
- `WORKDIR /app`; copies `./start.sh` (chmod +x), `./app`, `./main.py`, `./requirements.txt`, `./version` into /app
- `pip install --upgrade pip`; `pip install --no-cache-dir -Ur requirements.txt`; `pip install git+https://github.com/AnthonyBloomer/tmdbv3api.git`

## Runtime deps
- requirements.txt (verified, no version pins; `#tmdbv3api` and first `#gunicorn` are commented, `gunicorn` is listed again uncommented at the end):
  ```
  plexapi, configparser, numpy, pillow, imagehash, schedule, flask, flask_script,
  flask_sqlalchemy, bootstrap-flask, flask_apscheduler, flask_wtf, wtforms,
  pymediainfo, tautulli, croniter, opencv-python-headless, flask_paginate, gunicorn
  ```
- System: mediainfo (media info scans for audio and HDR10+ banners), ffmpeg (listed upstream), nginx.
- External: Plex server; TMDB API key (optional).

## Binaries/entrypoint/CLI flags
- `CMD ["/app/start.sh"]`; no ENTRYPOINT.
- start.sh (per plan, not refetched here): nginx on port 80 reverse-proxying to gunicorn on 5000.

## Env vars (table)
| Name | Default | Source / notes |
| --- | --- | --- |
| TZ | Europe/London (Dockerfile ARG); examples use Europe/London | Dockerfile, wiki |
| PUID | 1000 (Linux example); Unraid: 99 | wiki (Docker Hub README spells it `PGUI`, likely typo) |
| PGID | 1000 (Linux example); Unraid: 100 | wiki |

- Config options (Plex URL, Plex token, library names, schedules, TMDB key, backup/banner toggles) are set in the web UI, not env vars (wiki Config-Settings). Plex URL format per wiki: `http://<ip>:32400`.

## Ports
- Docker Hub run example: `-p 5000:5000` (web UI on 5000).
- Dockerfile: `EXPOSE 80 5000`.
- Wiki install page: `-p 80:80` ("only one is needed").
- TrueCharts chart: service port 10380 -> target port 80.
- CONFLICT: sources disagree on the UI port (5000 vs 80). The Dockerfile exposes both.

## Volumes/paths and persistent data
- `/config`: config database (SQLite per plan). Pre-GUI config files placed here are auto-imported on first run (wiki).
- `/logs`: log storage.
- `/films`: Plex media root. Wiki says mount the top-level directory holding all media. Compose example mounts it read-only; the app needs write access to media dirs if poster backups are enabled (Config-Settings says container needs write access to the Plex media directories if backups are on).
- Poster backups saved as `poster_bak.png` beside the media; backups folder named by Plex GUID (Docker Hub page).
- Dockerfile declares `VOLUME /films`, `VOLUME /config`, `VOLUME /logs`.

## User/UID & permissions
- Dockerfile has no USER instruction; runs as root by default.
- Wiki: PUID/PGID must match the user owning the Plex directories.

## Config files and formats
- Database (SQLite) in config dir; migration from old script config files and old HDR banners handled by the app.
- Config option names are not documented in the fetched wiki pages.

## Healthcheck/readiness endpoints
- None documented.

## Version/release info and asset naming
- Releases (GitHub): 21.12 / tag `0.21.12` (Latest, commit cb1cde4), `0.21.9-beta` (478c7e9, pre-release), `0.21.6-beta` (9686c7b, pre-release). Each release shows 2 assets; asset file names not visible in the fetch.
- No release tagged 23.02.02 is listed on the releases page. The Docker Hub `latest` tag is the only tag shown there (digest sha256:33ca56a9...).
- Repo Dockerfile pins nothing; base is `python:3.9.16-slim-bullseye`.

## Arch support
- Not stated on repo or Docker Hub page.

## Gotchas
- Docker Hub page says "designed to run in docker only".
- Docker Hub shows the run example with `-v <media>:/films -v <logs>:/logs`, and `/config` mount for migration.
- Discord support: https://discord.gg/z3FYhHwHMw
- Wiki says the browser UI is at the mapped port 80; the Dockerfile and Docker Hub use 5000.

## Contradictions with plan.md
- Plan says port 80 (nginx) is not needed and the app listens on 5000 only. The wiki and TrueCharts use port 80 for the UI. Not resolved by these sources. Left as unverified in README.
- Plan says `UID`/`GID` from the upstream compose are not read. The wiki documents `PUID`/`PGID`, a different name. Plan's claim is code-based and was not checked here.
