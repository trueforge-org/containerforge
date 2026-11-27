# TrueCharts chart: zurg

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/zurg/values.yaml and .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `zurg` v5.0.0, appVersion 0.9.3. Description "zurg Self-Hosted". Category security.
- Dependency: `common` 32.8.5 (oci://oci.trueforge.org/truecharts). kubeVersion >=1.33.0-0.

## Image (values.yaml)
- repository: `ghcr.io/geek-cookbook/zurg` (third-party rebuild, see github-geek-cookbook-zurg-dockerfile.md)
- tag: `v0.9.3-hotfix.11@sha256:f3110e087387d0584700d43708121135f6b2880290711c682d9f817a0637a3f6`
- pullPolicy: IfNotPresent

## Ports
| name | port | targetPort |
| --- | --- | --- |
| main | 9999 | 9999 |

## Probes (values.yaml)
- liveness, readiness, startup: type tcp (port default main).

## Persistence
| name | source | mountPath |
| --- | --- | --- |
| config | persistence | /config |
| data | persistence | /app/data |
| config-file | configmap config-file, subPath config.yml | /config/config.yml |
| plexupdate-file | configmap plexupdate-file, subPath plex_update.sh | /config/plex_update.sh |

## Env vars (chart values)
| Env | Value |
| --- | --- |
| zurg_FORCE_ENV | "true" (comment: forces env vars to be used) |
| LOG_LEVEL | DEBUG |

## Chart values
- `zurg.token`: "YOURTOKEN" (placeholder; rendered into configmap config.yml as `token:`).

## ConfigMaps (rendered from chart)
- config-file -> config.yml: zurg v1; host "[::]"; port 9999; concurrent_workers 32; check_for_changes_every_secs 10; retain_folder_name_extension false; retain_rd_torrent_name true; auto_delete_rar_torrents true; use_download_cache false; enable_repair false; `on_library_update: sh plex_update.sh "$@"`; ignore_renames true; network_buffer_size 1048576; serve_from_rclone false; verify_download_link true; force_ipv6 false; rate_limit_sleep_secs 6; realdebrid_timeout_secs 60; retries_until_failed 5.
- directories: anime (group media, order 10), shows (media, 20), movies (media, 30, only_show_the_biggest_file) with filters.
- plexupdate-file -> plex_update.sh (Plex partial scan script).

## Gotchas
- Token is written in plaintext into a configmap (`zurg.token`).
- Chart appVersion 0.9.3 vs upstream zurg-public README stable "v1.0.0" (conflict, see github-zurg-public-readme.md). Not edited.
- Config at /config/config.yml, but geek-cookbook image WORKDIR /config and binary at /app/zurg (see Dockerfile summary). Entrypoint (apps/zurg/entrypoint.sh in geek-cookbook) not fetched.
