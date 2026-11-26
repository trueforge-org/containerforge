# TrueCharts chart: icloudpd

Source URL(s) + fetch date: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/icloudpd (chart dir); values read from https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/icloudpd/values.yaml · fetched 2026-11-26

## What it is
TrueCharts Helm chart for icloudpd, using `docker.io/boredazfcuk/icloudpd` (a third-party Alpine image, not the upstream project image).

## Container settings in the chart
- Image: `docker.io/boredazfcuk/icloudpd`, tag `1.0.826@sha256:104bcac4ef61bd471287ddd641d287bb3e97fc077a515a70448596661bfbe2f6`, pullPolicy `IfNotPresent`.
- runAsUser / runAsGroup: `0`; runAsNonRoot: `false`; readOnlyRootFilesystem: `false`; privileged not set.
- Capabilities add: `NET_RAW`, `NET_ADMIN`.
- Chart's `main` service and port are disabled; probes disabled.

## Env vars (table, as templated by the chart)
| Name | Source value |
| --- | --- |
| user / group | `apps` / `apps` |
| user_id / group_id | from runAsUser / runAsGroup (0) |
| download_path, jpeg_path | `/home/apps/iCloud` |
| apple_id, synchronisation_interval, synchronisation_delay, notification_days, authentication_type, photo_size, live_photo_size, photo_album, jpeg_quality, command_line_options, notification_title, notification_type | from `.Values.icloudpd.*` |
| skip_check, download_notifications, delete_notifications, delete_accompanying, delete_empty_directories, set_exif_datetime, auto_delete, skip_live_photos, skip_videos, convert_heic_to_jpeg | ternary True/False from booleans |
| icloud_china, recent_only, until_found | special-cased templates |

## Ports
- None enabled (main service disabled).

## Volumes/paths and persistent data
- `config` at `/config` (enabled).
- `data` at `/home/apps/iCloud` (enabled).

## Gotchas
- Chart runs as UID 0 and adds NET_RAW and NET_ADMIN. Plan.md drops both (CLI needs no raw sockets) and uses `/data`, not `/home/apps/iCloud`. This is a deliberate change.
- The chart uses the boredazfcuk image, which is a different program wrapper, not the upstream `icloudpd` binary. Plan.md builds from the upstream release binary.
