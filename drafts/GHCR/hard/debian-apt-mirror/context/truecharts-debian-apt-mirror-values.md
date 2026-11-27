# TrueCharts debian-apt-mirror values.yaml

Source URL: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/debian-apt-mirror/values.yaml (fetched 2026-11-27)

## Image
- repository: `ghcr.io/ich777/debian-mirror`
- tag: `latest@sha256:5655e1d17dd35351c25f2e02b105c6ae694d6b0d7a30e957182d6dad016c6233`
- pullPolicy: IfNotPresent

## Ports
- service.main.ports.main: port 980, targetPort 980, protocol tcp
- Env `APACHE2_PORT` = "980"

## Env (set by chart)
| Name | Value |
| --- | --- |
| DATA_DIR | /debian-mirror |
| CONFIG_DIR | /debian-mirror/config |
| MIRROR_DIR | /debian-mirror/data |
| APACHE2_PORT | 980 |
| CRON_SCHEDULE | 0 1 * * * |
| FORCE_UPDATE | false |
| DATA_PERM | 770 |

## Persistence
| Name | mountPath |
| --- | --- |
| config | /debian-mirror/config |
| data | /debian-mirror/data |
| base | /debian-mirror |

## Security context (chart)
- readOnlyRootFilesystem: false, runAsUser: 0, runAsGroup: 0 (root)

## Gotchas
- Chart pins image tag `latest` with digest only; appVersion is `latest` (Chart.yaml).
- Chart mounts `base` at /debian-mirror and also `config`/`data` under it.
