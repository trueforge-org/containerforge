# TrueCharts plexanisync chart

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/plexanisync/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/plexanisync/Chart.yaml
- Fetched 2026-11-27

## What it is
- "Plex to AniList Sync." Chart version 12.0.0, appVersion 1.4.4, train stable, keywords plexanisync/media
- Dependency: `common` 32.8.5 (oci://oci.trueforge.org/truecharts)
- Chart sources: ghcr.io/rickdb/plexanisync, github RickDB/PlexAniSync

## Image (values.yaml)
- repository: `ghcr.io/rickdb/plexanisync` (GHCR, no Docker Hub source)
- tag: `1.4.4@sha256:c42034ced809b3a2a9b74139b1a3f5dade31af4d18a413b6f49da37b55ab9f18`

## Security context
- runAsNonRoot false, runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false

## Chart values (plexanisync.*)
| Key | Default |
| --- | --- |
| interval | 3600 |
| plex.anime_section | [] |
| plex.plex_auth_method | direct (or myplex) |
| plex.myplex_server / myplex_user / myplex_token | "" |
| plex.plex_url / plex_token | "" |
| plex.home_user_sync | false |
| plex.home_username / home_server_url | "" |
| anilist.ani_username / ani_token | "" |
| anilist.plex_ep_count_priority | false |
| anilist.skip_list_update | false |
| anilist.log_failed_matches | false |
| custom_mappings | [] |

## Env / probes / service
- workload.main container: envFrom configMapRef `config`; all probes (liveness, readiness, startup) disabled
- service.main: enabled false (no ports exposed)

## Persistence
| Name | Type | Mount | Notes |
| --- | --- | --- | --- |
| settings | secret (object `secret`, key settings.ini) | /plexanisync/settings.ini | readOnly true, defaultMode 0600, subPath settings.ini |

## Gotchas
- settings.ini is mounted read-only at /plexanisync/settings.ini. Default runsync.sh path (SETTINGS_FILE unset) runs settingsupdater.py, which writes that same path. See `plexanisync-runsync.md` and `plexanisync-settingsupdater.md`.
