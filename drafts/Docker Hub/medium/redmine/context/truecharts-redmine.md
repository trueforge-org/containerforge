# TrueCharts chart: redmine

Source URL(s):
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/redmine/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/redmine/Chart.yaml
Fetched: 2026-11-27

## Chart.yaml
| Key | Value |
| --- | --- |
| version | 18.0.0 |
| appVersion | 6.1.0 |
| category | productivity |
| kubeVersion | >=1.33.0-0 |
| dependency | common 32.8.5 (oci://oci.trueforge.org/truecharts) |
| sources | github.com/redmine/redmine; hub.docker.com/_/redmine |

## values.yaml
| Key | Value |
| --- | --- |
| image.repository | docker.io/redmine |
| image.tag | 6.1.0 (no digest pin) |
| image.pullPolicy | IfNotPresent |
| redmine.secretKeyBase | placeholder string; must be replaced (comment: random string of at least 80 chars) |
| redmine.plugins_migrate | true |
| redmine.no_db_migrate | false |
| service.main.ports.main | port 10171, targetPort 3000 |
| persistence.data | enabled, mountPath `/usr/src/redmine/files` |
| dependencies.postgresql | enabled; username `redmine`, database `redmine` |
| securityContext.container | readOnlyRootFilesystem false, runAsUser 999, runAsGroup 999 |
| securityContext.pod.fsGroup | 999 |

## Env (chart, workload.main container main)
| Name | Value |
| --- | --- |
| REDMINE_DB_DATABASE | redmine (from depconfig) |
| REDMINE_DB_USERNAME | redmine (from depconfig) |
| REDMINE_DB_PORT | "5432" |
| REDMINE_NO_DB_MIGRATE | ternary: "true" if no_db_migrate set, else empty |
| REDMINE_PLUGINS_MIGRATE | ternary: "true" if plugins_migrate set, else empty |
| REDMINE_DB_PASSWORD | secretKeyRef `<release>-postgresqlcreds` key `postgresql-password` |
| REDMINE_DB_POSTGRES | secretKeyRef `<release>-postgresqlcreds` key `plainhost` |
| REDMINE_SECRET_KEY_BASE | secretKeyRef `secrets` key `REDMINE_SECRET_KEY_BASE` |

## Ports
- Service 10171 -> container 3000 (Redmine `rails server`, EXPOSE 3000 in image).

## Volumes/paths
- `/usr/src/redmine/files` (uploaded files; image VOLUME).

## User/UID
- uid/gid 999 (redmine user), pod fsGroup 999. Matches image.

## Gotchas
- Image tag `6.1.0` is not pinned by digest; the Docker Hub tag list (page 1) did not show a `6.1.0` tag (see dockerhub-redmine.md).
- Secret key base placeholder in values must be replaced.
- Postgres is a chart dependency; the image's DB adapter is selected by REDMINE_DB_POSTGRES.
