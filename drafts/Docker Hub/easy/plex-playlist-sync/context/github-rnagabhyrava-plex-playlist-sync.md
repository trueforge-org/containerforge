# rnagabhyrava/plex-playlist-sync

**Source URL(s) + fetch date**
- https://raw.githubusercontent.com/rnagabhyrava/plex-playlist-sync/v1.0.2/Dockerfile
- https://raw.githubusercontent.com/rnagabhyrava/plex-playlist-sync/v1.0.2/README.md
- https://raw.githubusercontent.com/rnagabhyrava/plex-playlist-sync/v1.0.2/plex-playlist-sync/run.py
- https://raw.githubusercontent.com/rnagabhyrava/plex-playlist-sync/v1.0.2/plex-playlist-sync/utils/plex.py
- https://raw.githubusercontent.com/rnagabhyrava/plex-playlist-sync/v1.0.2/requirements.txt
- https://raw.githubusercontent.com/rnagabhyrava/plex-playlist-sync/v1.0.2/LICENSE.md
- https://api.github.com/repos/rnagabhyrava/plex-playlist-sync (archive status, license SPDX)
- https://api.github.com/repos/rnagabhyrava/plex-playlist-sync/releases/tags/v1.0.2
- Fetched 2026-11-26. The draft's Dockerfile blob `c3333a5...` and `requirements.txt` at `HEAD` were not fetched; tag `v1.0.2` read instead.

**Status**
- ARCHIVED (GitHub API `archived: true`). API `pushed_at`: 2023-12-15T21:02:53Z. Default branch `main`.

**What it is**
- "App to recreate spotify/deezer playlists in your local plex server." Builds Plex playlists from Spotify user playlists and Deezer profile/playlists, using tracks already on the Plex server. Does not download music. Loops forever; sleeps between passes. License GPL-3.0 (LICENSE.md is the GPLv3 text).

**Install/build steps and build deps**
- Upstream Dockerfile (v1.0.2), verbatim:
  ```
  FROM python:3.10-alpine
  ENV PYTHONUNBUFFERED 1
  WORKDIR /app
  COPY requirements.txt requirements.txt
  RUN pip install -r requirements.txt
  COPY . .
  WORKDIR /app
  CMD ["python", "./plex-playlist-sync/run.py"]
  ```
- No EXPOSE, USER, VOLUME, HEALTHCHECK. `WORKDIR /app`; repo code sits in `/app/plex-playlist-sync/` (inner folder of the same name).
- Requirements (v1.0.2, verbatim):
  ```
  spotipy>=2.18.0
  plexapi>=4.7.0
  deezer-python>=2.3.0
  ```
  (plan.md had `plexapi==4.11.2`; that pin is not in the v1.0.2 file. Plan corrected.)

**Runtime deps**
- Python 3 with `spotipy`, `plexapi`, `deezer-python`. Network reach to Plex (`PLEX_URL`), Spotify and Deezer APIs.

**Binaries/entrypoint/CLI flags**
- `python ./plex-playlist-sync/run.py` (upstream CMD). No CLI flags; config from env only (`os.getenv`).

**Env vars** (from `run.py`, v1.0.2)
| Name | Default | Notes |
| --- | --- | --- |
| `PLEX_URL` | none | README: include `http://`; missing -> `Missing Plex Authorization Variables`, loop breaks |
| `PLEX_TOKEN` | none | Plex auth token |
| `WRITE_MISSING_AS_CSV` | `"0"` | enabled only when `"1"`; writes missing tracks to `/data` |
| `ADD_PLAYLIST_POSTER` | `"1"` | enabled only when `"1"` |
| `ADD_PLAYLIST_DESCRIPTION` | `"1"` | enabled only when `"1"` |
| `APPEND_INSTEAD_OF_SYNC` | `False` | compared against `"1"`. README comment labels `1 = Sync tracks, 0 = Append only`, which contradicts the variable name and code (`"1"` appends). Code is taken as the meaning. |
| `SECONDS_TO_WAIT` | `86400` | cast to int; README example 84000 |
| `SPOTIFY_CLIENT_ID` | none | Spotify developer app |
| `SPOTIFY_CLIENT_SECRET` | none | |
| `SPOTIFY_USER_ID` | none | syncs all public playlists of that user |
| `DEEZER_USER_ID` | none | Deezer profile ID (public playlists) |
| `DEEZER_PLAYLIST_ID` | none | space-separated; passed raw to `deezer_playlist_ids` (no split in `run.py`) |
- `APPEND_SERVICE_SUFFIX`: not read in `run.py`; `utils/plex.py` reads no env at all. Chart templates it, so it is read elsewhere or unused (not verified).

**Ports**
- None. Pure client.

**Volumes/paths and persistent data**
- `utils/plex.py`: `_write_csv(tracks, name, path="/data")` and `_delete_csv(name, path="/data")`. `_write_csv` runs `data_folder.mkdir(parents=True, exist_ok=True)`; `_delete_csv` only unlinks. `update_or_create_plex_playlist` never passes a path, so `/data` is always used. Output only when `WRITE_MISSING_AS_CSV=1`.
- README: map a host path to `/data` for missing-track output.

**User/UID & permissions**
- Upstream image has no USER (root).

**Config files and formats**
- None; env only. Missing-track CSV files written to `/data`.

**Healthcheck/readiness endpoints**
- None.

**Version/release info and asset naming**
- Release `v1.0.2`, published 2022-07-12T22:55:06Z, not prerelease. Assets: none (empty list).
- Source archive: `https://github.com/rnagabhyrava/plex-playlist-sync/archive/refs/tags/v<version>.tar.gz` (plan.md).

**Arch support**
- Docker Hub lists amd64, arm64, arm/v7 (see Docker Hub summary). Pure Python.

**Gotchas**
- Plex failure paths `break` out of the loop; the process exits (exit code 0 per plan.md).
- Spotify problems only log at info level and skip that section; no exit.
- `SECONDS_TO_WAIT` sleeps between passes.
- README's `DEEZER_USER_ID` note in compose says "spotify user id" (typo in upstream compose comment).
- Plan check: requirements (plexapi lower bound, not `==4.11.2`), Dockerfile base and CMD, `/data` hard-coded CSV path, env defaults, failure log strings, archived status and GPL-3.0 match the source. License: LICENSE.md is GPLv3 text; the "or any later version" wording appears only in the sample notice, so the `-only` vs `-or-later` choice is still unresolved from this file.
