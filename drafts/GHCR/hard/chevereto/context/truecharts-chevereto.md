# TrueCharts chart: chevereto

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/chevereto/values.yaml and .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `chevereto` version 21.0.0, appVersion 1.6.2, train stable, category incubator.
- Image: `ghcr.io/rodber/chevereto-free` tag `1.6.2@sha256:2e3a78eff5ade90d72cceb63fa9dba4b539f1def55debc0c23b15fb08d6e549b`, pullPolicy IfNotPresent.
- Dependency: `common` 32.8.5 (oci://oci.trueforge.org/truecharts), plus `mariadb` (enabled, depconfig user/db `chevereto`).
- kubeVersion >=1.33.0-0.

## Ports
| Name | Container port | Protocol | Service port |
| --- | --- | --- | --- |
| main | 80 | http | 10197 |

## Env vars (chart-set)
| Var | Value |
| --- | --- |
| CHEVERETO_HTTPS | from `chevereto.https` (false -> "0") |
| CHEVERETO_DISABLE_UPDATE_HTTP | from `chevereto.disable_update_http` (true -> "1") |
| CHEVERETO_DISABLE_UPDATE_CLI | from `chevereto.disable_update_cli` (true -> "1") |
| CHEVERETO_DB_DRIVER | mysql |
| CHEVERETO_DB_NAME | `.Values.dependencies.mariadb.depconfig.mariadbUsername` (= `chevereto`) |
| CHEVERETO_DB_USER | `.Values.dependencies.mariadb.depconfig.mariadbDatabase` (= `chevereto`) |
| CHEVERETO_DB_PORT | 3306 |
| CHEVERETO_TAG | free |
| CHEVERETO_DB_HOST | secret `<release>-mariadbcreds`, key `plainporthost` |
| CHEVERETO_DB_PASS | secret `<release>-mariadbcreds`, key `mariadb-password` |

Also `envFrom` configMap `chevereto` (holds the three CHEVERETO_* flags above).

## Volumes/paths
| Persistence | Mount path |
| --- | --- |
| storage | /var/www/html/images/ |
| content | /var/www/html/content/ |

## User/UID
- securityContext.container: runAsNonRoot false, runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.
- pod fsGroup 33 (www-data in php:apache images).

## Probes
- liveness, readiness, startup: all `type: http`, path `/`.

## Gotchas
- Chart sets CHEVERETO_DB_NAME and CHEVERETO_DB_USER from swapped depconfig keys (name <- mariadbUsername, user <- mariadbDatabase). Both are `chevereto` so no effect today, but it is a latent swap.
- Chart runs as root with readOnlyRootFilesystem false.
- CHEVERETO_TAG=free is set in env but is not in the upstream Dockerfile env list read in the plan.
