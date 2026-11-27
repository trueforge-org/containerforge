# RickDB PlexAniSync Docker README (v1.4.4)

## Source URL(s) + date
- https://raw.githubusercontent.com/RickDB/PlexAniSync/v1.4.4/Docker/PlexAniSync/README.md (fetched 2026-11-27)

## Run
- Image in docs: `ghcr.io/rickdb/plexanisync:latest`
- Mount: `/etc/localtime:/etc/localtime:ro` (optional), `custom_mappings.yaml` to `/plexanisync/custom_mappings.yaml`
- Custom settings: mount ini ro (e.g. `/config/settings.ini`) and set `SETTINGS_FILE=/config/settings.ini`

## Env vars (README table)
| ID | Default | Required | Note |
| --- | --- | --- | --- |
| PLEX_SECTION | Anime | yes* | library name(s), separated with \| |
| PLEX_URL | http://127.0.0.1:32400 | yes* | Plex server URL |
| PLEX_TOKEN | - | yes* | Plex auth token |
| ANI_USERNAME | - | yes* | AniList username |
| ANI_TOKEN | - | yes* | AniList token (OAuth) |
| PLEX_EPISODE_COUNT_PRIORITY | - | no | Plex watched count over AniList |
| SYNC_RATINGS | - | no | Plex ratings used for AniList scores |
| SKIP_LIST_UPDATE | - | no | test run, no AniList update |
| LOG_FAILED_MATCHES | - | no | writes /plexanisync/failed_matches.txt |
| SETTINGS_FILE | - | no | custom settings.ini; makes the above obsolete |
| INTERVAL | 3600 | no | seconds; <= 0 stops after first sync |

## Gotchas
- Docs say the ini settings mapping replaces env vars when SETTINGS_FILE is set.
- `*` required unless SETTINGS_FILE is used.
