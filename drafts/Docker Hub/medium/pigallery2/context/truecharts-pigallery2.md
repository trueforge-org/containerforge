# TrueCharts chart: pigallery2

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/pigallery2/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/pigallery2/Chart.yaml
- Fetched 2026-11-27

## What it is
- Helm chart `pigallery2`, chart version 11.0.0, appVersion `latest`.
- Library dependency `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`.

## Image
| Key | Value |
| --- | --- |
| repository | docker.io/bpatrik/pigallery2 |
| tag | latest@sha256:11c93ac881c1422a2385805e52ad84714bd401f2b659e78dd4384aa90254a1e1 |
| pullPolicy | IfNotPresent |

## Ports
| Service | Port | Protocol | Target |
| --- | --- | --- | --- |
| main | 80 | tcp | 80 |

## Volumes/paths
| Persistence | Mount | Notes |
| --- | --- | --- |
| config | /app/data/config | |
| db | /app/data/db | |
| image | /app/data/images/ | readOnly true |
| tmp | /app/data/tmp | |

## Env vars
- None set in values.

## User/UID
- Container: runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.

## Probes
- None defined.

## Gotchas
- Chart runs as root.
- Chart port is 80; upstream image also listens on 80.
