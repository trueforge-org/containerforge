# TrueCharts chart: pgadmin

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/pgadmin/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/pgadmin/Chart.yaml
- Fetched 2026-11-27

## What it is
- Helm chart `pgadmin`, chart version 22.0.0, appVersion 9.19.0.
- Library dependency `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`.

## Image
| Key | Value |
| --- | --- |
| repository | docker.io/dpage/pgadmin4 |
| tag | 9.19@sha256:3591b3d02910dcd817dec6fcaa681c278ba6966945283dd0ea0042731c330c83 |
| pullPolicy | IfNotPresent |

## Ports
| Service | Port | Target |
| --- | --- | --- |
| main | 10024 | 8080 |

## Env vars (workload main container)
| Name | Value / source |
| --- | --- |
| PGADMIN_DEFAULT_EMAIL | `replace@this.now` (placeholder) |
| PGADMIN_DEFAULT_PASSWORD | secretKeyRef `env-secrets`, key `PGADMIN_DEFAULT_PASSWORD` (secret default `changeme`) |

## Volumes/paths
| Persistence | Mount |
| --- | --- |
| config | /var/lib/pgadmin |

## User/UID
- Container: runAsNonRoot true, runAsUser 5050, runAsGroup 5050.
- Pod: fsGroup 5050.

## Probes
- liveness, readiness, startup: HTTP GET `/misc/ping`.

## Config files
- values.yaml carries a schema comment pointing to `./values.schema.json` (not fetched).

## Gotchas
- readOnlyRootFilesystem is false in the chart.
- Chart targetPort is 8080, while upstream Dockerfile `EXPOSE` is 80 and 443 (chart and upstream disagree; not resolved by fetched files).
- Default password `changeme` in the chart secret.
