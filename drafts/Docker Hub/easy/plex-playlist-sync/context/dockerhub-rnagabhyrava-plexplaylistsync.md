# rnagabhyrava/plexplaylistsync (Docker Hub)

**Source URL(s) + fetch date**
- https://hub.docker.com/r/rnagabhyrava/plexplaylistsync (fetched 2026-11-26)

**What it is**
- Builds Plex playlists from Spotify and Deezer playlists using tracks already on the Plex server; keeps them aligned. Does not download songs.

**Version/release info and asset naming**
- Only tag: `latest` (about 62.9 MB, digest begins `sha256:c9e85cb9d...`). Last updated over 4 years ago.
- Chart pins `latest@sha256:c9e85cb9def574004602c5a37b25b360b635fd4547e274fb1572318068180cf4`, same digest prefix. No version tag exists on the Hub page.

**Arch support**
- amd64, arm64, arm/v7 (Hub page; platform picked automatically).

**Install/run**
- `docker run -d --name=playlistSync --restart unless-stopped -v <path>:/data -e ...`; compose service `playlistSync` (`version: "2.1"` in README example).
- README: include `http://` in `PLEX_URL`.

**Ports**
- None specified.

**Volumes**
- Host path to `/data` for missing-track output; needed only when `WRITE_MISSING_AS_CSV=1`.

**Env vars**
- Required: `PLEX_URL`, `PLEX_TOKEN`. At least one of: Spotify (`SPOTIFY_CLIENT_ID`, `SPOTIFY_CLIENT_SECRET`, `SPOTIFY_USER_ID`), Deezer profile (`DEEZER_USER_ID`), Deezer playlists (`DEEZER_PLAYLIST_ID`, space-separated).
- Optional with defaults: `WRITE_MISSING_AS_CSV` 0, `ADD_PLAYLIST_POSTER` 1, `ADD_PLAYLIST_DESCRIPTION` 1, `APPEND_INSTEAD_OF_SYNC` 0 (page comment: `1 = sync, 0 = append only`, which conflicts with the code), `SECONDS_TO_WAIT` (example 84000; code default 86400).

**Gotchas**
- Page does not state an archived notice; the GitHub API does (see GitHub summary).
- Page's `APPEND_INSTEAD_OF_SYNC` comment contradicts code behaviour.
