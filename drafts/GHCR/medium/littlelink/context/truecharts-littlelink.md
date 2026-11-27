# TrueCharts littlelink chart (stable)

Source URL(s) + date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/littlelink/values.yaml (2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/littlelink/Chart.yaml (2026-11-27)

## What it is
- Chart `littlelink` version 20.0.0, appVersion `latest`, category social, train stable.
- Depends on `common` 32.8.5 (oci://oci.trueforge.org/truecharts).
- Sources listed: ghcr.io/techno-tim/littlelink-server, github sethcottle/littlelink, github techno-tim/littlelink-server.

## Image
- repository: `ghcr.io/techno-tim/littlelink-server`
- tag: `latest@sha256:e84ea9d93b60362cf9e292dba43adb604e375d9206d5fcf1de6bb766a20aabd1`
- pullPolicy: IfNotPresent

## Ports
| name | port | targetPort |
| --- | --- | --- |
| main | 10040 | 3000 |

## Env (set by chart)
| var | value |
| --- | --- |
| META_TITLE | "techno tim" |
| META_DESCRIPTION | "techno tim link page" |
| META_AUTHOR | "techno tim" |

Chart comment: "See upstream for more ENV".

## Kubernetes
- kubeVersion `>=1.33.0-0`, helm min 3.14, max 4.1.

## Gotchas
- Chart pins the upstream image by `latest` plus digest; this container's own tag scheme is not implied by the chart.
