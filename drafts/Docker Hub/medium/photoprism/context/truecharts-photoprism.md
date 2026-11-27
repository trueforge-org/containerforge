# TrueCharts chart: photoprism

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/photoprism/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/photoprism/Chart.yaml
- Fetched 2026-11-27

## What it is
- Helm chart `photoprism`, chart version 33.0.0, appVersion 251130.0.0.
- Library dependency `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`.
- Dependency: mariadb enabled (user `photoprism`, database `photoprism`).

## Image
| Key | Value |
| --- | --- |
| repository | docker.io/photoprism/photoprism |
| tag | 251130@sha256:db16ee6b1ba3e5bc5ad787a3141a082532d1b30932c8b1396fa609394374b83f |
| pullPolicy | IfNotPresent |

## Ports
| Service | Port | Target |
| --- | --- | --- |
| main | 2342 | 2342 |

## Volumes/paths
| Persistence | Mount | Type |
| --- | --- | --- |
| storage | /assets | chart storage |
| photoprismtemp | /photoprism_temp | emptyDir |
| originals | /photoprism/originals | chart storage |
| import | /photoprism/import | chart storage |

## Env vars (main container)
| Name | Value / source |
| --- | --- |
| HOME | /photoprism |
| PHOTOPRISM_ORIGINALS_PATH | /photoprism/originals |
| PHOTOPRISM_IMPORT_PATH | /photoprism/import |
| PHOTOPRISM_TEMP_PATH | /photoprism_temp |
| PHOTOPRISM_STORAGE_PATH | /assets/storage |
| PHOTOPRISM_SIDECAR_PATH | /assets/sidecar |
| PHOTOPRISM_CACHE_PATH | /assets/cache |
| PHOTOPRISM_CONFIG_PATH | /assets/config |
| PROTOPRISM_BACKUP_PATH | /assets/backup (misspelled name in source) |
| PHOTOPRISM_PUBLIC | false |
| PHOTOPRISM_UID / _GID / _UMASK | templated from securityContext.container runAsUser / runAsGroup / UMASK |
| PHOTOPRISM_DATABASE_DRIVER | mysql |
| PHOTOPRISM_DATABASE_NAME | photoprism |
| PHOTOPRISM_DATABASE_USER | photoprism |
| PHOTOPRISM_DATABASE_SERVER | secretKeyRef `<Release>-mariadbcreds`, key `plainporthost` |
| PHOTOPRISM_DATABASE_PASSWORD | secretKeyRef `<Release>-mariadbcreds`, key `mariadb-password` |
| PHOTOPRISM_ADMIN_PASSWORD | secretKeyRef `env-secrets`, key `PHOTOPRISM_ADMIN_PASSWORD` (secret default `please-change`) |

## User/UID
- Container: runAsNonRoot false, runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.

## Probes
- None defined.

## Gotchas
- Chart runs as root and defaults to MariaDB; upstream default is SQLite.
- Chart image tag `251130` is older than latest release `261029-963b58c50` (see github-photoprism.md).
- Key `plainporthost` in the mariadbcreds secret is a literal key name in the chart (as written).
