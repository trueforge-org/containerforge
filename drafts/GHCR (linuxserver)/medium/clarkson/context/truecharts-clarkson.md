# TrueCharts chart: clarkson
Source: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/clarkson/values.yaml and .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart clarkson 21.0.0, appVersion 1.1.2
- Home https://truecharts.org/charts/stable/clarkson
- Sources: https://ghcr.io/linuxserver/clarkson, https://github.com/linuxserver/Clarkson

## Dependencies
- common 32.8.5 from oci://oci.trueforge.org/truecharts
- MariaDB enabled: database and username both `clarkson`

## Image
- ghcr.io/linuxserver/clarkson, tag 1.1.2 (sha256 pinned), pullPolicy IfNotPresent
- Deployment strategy Recreate

## Ports
- Service main 10244 -> container targetPort 3000 (http)

## Env vars (workload main container)
| Name | Source |
|---|---|
| MYSQL_USERNAME | templated from dependencies.mariadb.depconfig.mariadbUsername (`clarkson`) |
| MYSQL_HOST | secretKeyRef key `plainhost` (release name + "mariadbcreds" secret) |
| MYSQL_PASSWORD | secretKeyRef key `mariadb-password`, same secret |

## Volumes/paths
- persistence {} empty: no volumes defined

## Probes
- None defined in chart

## User/UID
- securityContext.container: runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false
