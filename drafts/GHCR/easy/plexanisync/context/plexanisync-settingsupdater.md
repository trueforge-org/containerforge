# RickDB PlexAniSync settingsupdater.py (Docker/PlexAniSync/run/, v1.4.4)

## Source URL(s) + date
- https://raw.githubusercontent.com/RickDB/PlexAniSync/v1.4.4/Docker/PlexAniSync/run/settingsupdater.py (fetched 2026-11-27)
- Root path `.../v1.4.4/settingsupdater.py` returned 404 (one alternative tried, then used the run/ path that Dockerfile COPYs)

## What it does
Writes `/plexanisync/settings.ini` (configparser) from env vars. Called by runsync.sh when SETTINGS_FILE is unset.

## Env -> ini mapping
| Env | ini section.key |
| --- | --- |
| PLEX_SECTION | PLEX.anime_section |
| (fixed) direct | PLEX.authentication_method |
| PLEX_URL | PLEX.base_url |
| PLEX_TOKEN | PLEX.token |
| ANI_USERNAME | ANILIST.username |
| ANI_TOKEN | ANILIST.access_token |
| PLEX_EPISODE_COUNT_PRIORITY | ANILIST.plex_episode_count_priority (default False) |
| SKIP_LIST_UPDATE | ANILIST.skip_list_update (default False) |
| LOG_FAILED_MATCHES | ANILIST.log_failed_matches (default False) |
| SYNC_RATINGS | ANILIST.sync_ratings (default False) |

## Paths
- Output: `/plexanisync/settings.ini` (absolute, hard-coded), opened with mode 'w'

## Gotchas
- Always overwrites settings.ini; fails if that path is a read-only mount (chart `truecharts-plexanisync.md`).
- SYNC_RATINGS and PLEX_EPISODE_COUNT_PRIORITY are read here but are not in the chart values.
