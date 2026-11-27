# TrueCharts youtubedl-material (charts/stable/youtubedl-material)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/youtubedl-material/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `youtubedl-material` v18.0.0, appVersion 2024.10.01, train stable, depends on `common` 32.8.5 and MongoDB (`dependencies.mongodb.enabled: true`, user/db `ytdl_material`).
- Sources: ghcr.io/tzahi12345/youtubedl-material, github.com/Tzahi12345/YoutubeDL-Material.

## Image
- `ghcr.io/tzahi12345/youtubedl-material`, tag `nightly-2024-10-01@sha256:b3d4da77...` (old nightly, pinned by chart).

## Ports
- service.main.ports.main: **10253** (also passed as env `ytdl_port`). Upstream Dockerfile EXPOSE 17442; upstream compose maps 8998:17442.

## Env (selected; full list in chart)
| Var | Value |
| --- | --- |
| ytdl_mongodb_connection_string | secretKeyRef `<release>-mongodbcreds` key `url` |
| ytdl_port | service port (10253) |
| ytdl_use_local_db | false |
| write_ytdl_config | true |
| ALLOW_CONFIG_MUTATIONS | true |
| ytdl_multi_user_mode | false |
| ytdl_allow_subscriptions | true |
| ytdl_subscriptions_check_interval | 86400 |
| ytdl_default_downloader | yt-dlp |
| ytdl_max_concurrent_downloads | 5 |
| ytdl_logger_level | debug |
| ytdl_jwt_expiration | 86400 |
| ytdl_api_key / ytdl_youtube_api_key / ytdl_twitch_api_key | secretKeyRef env-secrets (empty defaults) |
| (others) | ytdl_url "", ytdl_title_top YoutubeDL-Material, ytdl_use_cookies false, ytdl_custom_args "", ytdl_download_rate_limit "", etc. |

## Volumes
| Name | Mount |
| --- | --- |
| appdata | /app/appdata |
| users | /app/users |
| subscriptions | /app/subscriptions |
| audio | /app/audio |
| video | /app/video |

## Security
- security.PUID 1000; securityContext.pod.fsGroup 1000.
- container: readOnlyRootFilesystem false, runAsNonRoot false, runAsUser 0, runAsGroup 0.

## Probes
- None overridden.
