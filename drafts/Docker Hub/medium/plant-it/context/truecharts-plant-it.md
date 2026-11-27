# TrueCharts chart: plant-it

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/plant-it/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/plant-it/Chart.yaml
- Fetched 2026-11-27

## What it is
- Helm chart `plant-it`, chart version 11.0.0, appVersion 0.10.0.
- Library dependency `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`.
- Dependencies: mariadb enabled (user `plantit`, database `plantit`); valkey enabled.

## Image
| Key | Value |
| --- | --- |
| repository | docker.io/msdeluise/plant-it-server |
| tag | 0.10.0@sha256:23ddf8660087d6b9f5dbdca2ca09817b84db45cb2d9d6e2e0176e70f514629e7 |
| pullPolicy | IfNotPresent |

## Ports
| Service | Port | Target |
| --- | --- | --- |
| main | 3000 | 3000 |
| api | 9701 | (api service port) |

## Env vars (main container)
| Name | Value / source |
| --- | --- |
| MYSQL_HOST | secretKeyRef `<Release>-mariadbcreds`, key `plainhost` |
| MYSQL_PORT | 3306 |
| MYSQL_USERNAME | templated from mariadb depconfig username |
| MYSQL_PSW | secretKeyRef `<Release>-mariadbcreds`, key `mariadb-password` |
| MYSQL_DATABASE | templated from mariadb depconfig database |
| MYSQL_ROOT_PASSWORD | secretKeyRef `<Release>-mariadbcreds`, key `mariadb-root-password` |
| JWT_SECRET | secretKeyRef `env-secrets`, key `JWT_SECRET` (chart default `MyJWTSecret`) |
| JWT_EXP | 1 |
| USER_LIMIT | -1 |
| UPLOAD_DIR | /uploads |
| API_PORT | templated from service.main.ports.api.port |
| TREFLE_KEY | secretKeyRef `env-secrets`, key `TREFLE_KEY` (chart default empty) |
| LOG_LEVEL | INFO |
| ALLOWED_ORIGINS | * |
| CACHE_TTL | 86400 |
| CACHE_HOST | secretKeyRef `<Release>-valkeycreds`, key `plainhost` |
| CACHE_PORT | 6379 |
| SSL_ENABLED | false |
| CERTIFICATE_PATH | /certificates/ |

- These names are chart-defined, not confirmed against upstream source (Dockerfile sets no ENV).

## Volumes/paths
| Persistence | Mount |
| --- | --- |
| uploads | /uploads |
| certificates | /certificates |
| varrun | disabled |

## User/UID
- Container: runAsNonRoot false, runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.

## Probes
- None defined.

## Gotchas
- Chart runs as root.
- Chart appVersion 0.10.0 (Docker Hub tag `0.10.0` from 2024-12-10).
