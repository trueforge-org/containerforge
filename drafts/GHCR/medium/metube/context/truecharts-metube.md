# TrueCharts metube chart (stable)

Source URL(s) + date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/metube/values.yaml (2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/metube/Chart.yaml (2026-11-27)

## What it is
- Chart `metube` version 20.0.1, appVersion 2026.11.24, category media, train stable.
- Depends on `common` 32.8.5 (oci://oci.trueforge.org/truecharts).

## Image
- repository: `ghcr.io/alexta69/metube`
- tag: `2026.11.24@sha256:c423654da5b9d29b02a8092713607b906d63d17fd7e0a2f52228218a0d3e2a7b`
- pullPolicy: IfNotPresent

## Ports
| name | port | targetPort |
| --- | --- | --- |
| main | 10216 | 8081 |

## Persistence
| name | mountPath |
| --- | --- |
| config | /config |
| downloads | /downloads |

## Env (chart workload)
| var | value |
| --- | --- |
| STATE_DIR | /config |
| DOWNLOAD_DIR | /downloads |
| OUTPUT_TEMPLATE | "%(title)s.%(ext)s" |
| YTDL_OPTIONS | "{}" |

Note: chart sets STATE_DIR to /config; upstream Dockerfile default is /downloads/.metube.

## Gotchas
- Chart tag and appVersion match the upstream release tag 2026.11.24 (values and Chart.yaml).
