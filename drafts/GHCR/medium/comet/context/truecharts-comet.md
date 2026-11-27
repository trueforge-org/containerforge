# TrueCharts comet (stable)
Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/comet/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart comet self-hosted; chart version 7.0.0; appVersion `latest`. Category security.
- Dependency common 32.8.5 (oci://oci.trueforge.org/truecharts). Kube >=1.33.0-0.

## Image
- repository: ghcr.io/g0ldyy/comet
- tag: latest@sha256:3dcb2b1802bcc45ea9c1f1206088985baa88a8321ab3cb3408976356bfa8bbb3
- pullPolicy: IfNotPresent

## Ports
| Name | port | targetPort |
| --- | --- | --- |
| main | 8000 | 8000 |

## Persistence
| Name | mountPath | Type |
| --- | --- | --- |
| data | /data | PVC |
| cache | /.cache | emptyDir |

## Env (values.yaml, container main)
| Name | Value / source |
| --- | --- |
| comet__Database__ConnectionString | secretKeyRef env-secrets (built from postgresql) |
| DATABASE_URL | secretKeyRef env-secrets |
| DATABASE_TYPE | postgresql |
| ADDON_ID | comet.selfhosted.org |
| ADDON_NAME | Comet \| Selfhosted |
| ZILEAN_URL | None |
| INDEXER_MANAGER_TYPE | None |
| INDEXER_MANAGER_TIMEOUT | "30" |
| GET_TORRENT_TIMEOUT | "5" |
| FASTAPI_WORKERS | "1" |
| SCRAPE_TORRENTIO | "False" |
(commented-out in chart: INDEXER_MANAGER_URL, INDEXER_MANAGER_API_KEY, INDEXER_MANAGER_INDEXERS, DEBRID_PROXY_URL)

## Dependencies / secrets
- postgresql subchart enabled; depconfig postgresqlUsername=comet, postgresqlDatabase=comet.
- Secret env-secrets: comet__Database__ConnectionString = `Host=<plainhost>;Port=5432;Database=comet;Username=comet;Password=<pw>`; DATABASE_URL = `comet:<pw>@<plainhost>:5432`.

## Gotchas
- Chart pins image by `latest` digest, not a versioned tag.
- Chart uses postgres; upstream Dockerfile default DB is SQLite (`Caching system ft. SQLite / PostgreSQL` per README).
