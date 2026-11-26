# TrueCharts chart clamav (values.yaml)

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/clamav (raw values.yaml: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/clamav/values.yaml) · fetched 2026-11-26

## Image
`docker.io/clamav/clamav:1.5.5` pinned by digest (`64e30c0b…9469614`), pullPolicy IfNotPresent.

## Ports
Main service port 3310 (protocol http). Milter service port entry 7357 (service disabled).

## Env
- CLAMAV_NO_CLAMD=false, CLAMAV_NO_FRESHCLAMD=false, CLAMAV_NO_MILTERD=true (template from milter disabled), CLAMD_STARTUP_TIMEOUT=1800, FRESHCLAM_CHECKS=1.

## Chart-level ClamAV settings
report_path `/logs`; cron enabled, every minute (`* * * * *`), date_format `+%m-%d-%Y_%H.%M.%S`, log_file_name `clamscan_report`, extra_args empty. Cron job history limits 5 failed / 2 successful.

## Persistence
- sigdatabase -> `/var/lib/clamav`; scandir -> `/scandir` (readOnly true); logs -> `/logs`.

## Security context
readOnlyRootFilesystem false, runAsNonRoot false, runAsUser 0, runAsGroup 0.

## Probes
Liveness, readiness, startup: exec `clamdcheck.sh`.

## Command
No container command/args defined.

## Gotchas
- The chart runs a scheduled `clamscan` cron job writing reports to `/logs`; that is chart-level, outside the image.
- Chart mounts scan targets read-only at `/scandir`.
