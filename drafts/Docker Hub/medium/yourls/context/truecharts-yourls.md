# TrueCharts chart: yourls

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/yourls/Chart.yaml (2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/yourls/values.yaml (2026-11-27)

## What it is
- Chart `yourls` v15.0.1, appVersion 1.10.6, train stable, category Cloud.
- Library dependency: `common` 32.8.5 (oci://oci.trueforge.org/truecharts).
- kubeVersion `>=1.33.0-0`; max Kubernetes 1.35.0; Helm 3.14 to 4.1.

## Image
- repository `yourls`, tag `1.10.6@sha256:4e5ec5cdc4be3470bf2a718a1b77c01525498c7b770119bd2a1ed669dd4c529a`
- pullPolicy IfNotPresent

## Runtime deps
- Bundled MariaDB dependency: `dependencies.mariadb.enabled: true`, `depconfig.mariadbUsername: yourls`, `mariadbDatabase: yourls`.

## Env vars (values.yaml `workload.main.podSpec.containers.main.env`)
| Name | Value in chart |
| --- | --- |
| YOURLS_DB_HOST | secretKeyRef `<release>-mariadbcreds` key `plainhost` |
| YOURLS_DB_NAME | `.Values.dependencies.mariadb.depconfig.mariadbDatabase` |
| YOURLS_DB_USER | `.Values.dependencies.mariadb.depconfig.mariadbUsername` |
| YOURLS_DB_PASS | secretKeyRef `<release>-mariadbcreds` key `mariadb-password` |
| YOURLS_PRIVATE | `false` |
| YOURLS_SITE | `.Values.chartContext.appUrl` |
| YOURLS_USER | `""` |
| YOURLS_PASS | secretKeyRef `env-secrets` key `YOURLS_PASS` |

- Commented-out in chart: YOURLS_HOURS_OFFSET.
- Secret `env-secrets` (enabled) has `YOURLS_PASS: ""`.

## Ports
- service.main.ports.main: port 8080, targetPort 8080, tcp.

## Security context
- `readOnlyRootFilesystem: false`
- `runAsUser: 0`, `runAsGroup: 0` (root)

## Gotchas
- Chart runs as root with a writable rootfs; official image defaults to www-data (see dockerhub-yourls.md).
- `YOURLS_USER` is set to empty string in chart values.
- Chart `YOURLS_PRIVATE: false` overrides the upstream default (`true` in config sample).
