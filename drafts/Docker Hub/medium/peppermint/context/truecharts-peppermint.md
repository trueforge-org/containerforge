# TrueCharts chart: peppermint

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/peppermint/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/peppermint/Chart.yaml
- Fetched 2026-11-27

## What it is
- Helm chart (TrueCharts) for Peppermint, issue management software.
- Chart name `peppermint`, version 7.0.0, appVersion `latest`.
- Library dependency: `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`.

## Image
| Key | Value |
| --- | --- |
| repository | docker.io/pepperlabs/peppermint |
| tag | latest@sha256:d13932713561c8d69baea49820ba2d42ea145b28193b6a7e33950a05812406fd |
| pullPolicy | IfNotPresent |

## Ports
| Name | Protocol | Container port | Service port |
| --- | --- | --- | --- |
| main | http | 3000 | 10699 |
| api | http | 5003 | 5003 (ClusterIP) |

## Env vars (workload main container)
| Name | Source |
| --- | --- |
| DB_USERNAME | `.Values.dependencies.postgresql.depconfig.postgresqlUsername` |
| DB_PASSWORD | secretKeyRef `<Release>-postgresqlcreds`, key `postgresql-password` |
| DB_HOST | secretKeyRef `<Release>-postgresqlcreds`, key `plainhost` |
| SECRET | secretKeyRef `peppermint-secrets`, key `SECRET` |
| API_URL | templated http URL from chart fullname + api service port |

## Other values
- `peppermint.secretKey`: placeholder; comment says replace with random string of 64+ chars.
- postgresql dependency enabled; user `peppermint`, database `peppermint`.

## Volumes/paths
- None defined.

## User/UID
- Container securityContext: runAsNonRoot false, runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.

## Healthcheck
- No probes defined in values.

## Gotchas
- Chart runs as root (UID 0) and does not use a read-only rootfs; not rootless as-is.
- `appVersion` is `latest` (unpinned); image pinned by digest only in values.
