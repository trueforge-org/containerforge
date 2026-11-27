# TrueCharts chart: xwiki

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/xwiki/Chart.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/xwiki/values.yaml (fetched 2026-11-27)

## What it is
- Chart `xwiki` version 20.0.0, appVersion 18.9.0, category `productivity`.
- Depends on `common` 32.8.5 (`oci://oci.trueforge.org/truecharts`) and postgresql dependency (enabled; user `xwiki`, database `xwiki`).
- kubeVersion `>=1.33.0-0`; min helm 3.14, max helm 4.1.

## Image
- `public.ecr.aws/docker/library/xwiki` tag `18.9.0-postgres-tomcat@sha256:244a5a3712f8604614f70160cb6c635130cdadac703ba83d06ac0cc287d1a9f6`, pullPolicy IfNotPresent.

## Ports
- `service.main.ports.main`: port 10208, targetPort 8080.

## Persistence
- `persistence.config`: enabled, mountPath `/usr/local/xwiki` (permanent directory).

## Security context
- `runAsUser: 0`, `runAsGroup: 0`, `runAsNonRoot: false`, `readOnlyRootFilesystem: false`.

## Env (main container)
| Name | Value |
| --- | --- |
| DB_USER | `{{ .Values.dependencies.postgresql.depconfig.postgresqlUsername }}` (xwiki) |
| DB_DATABASE | `{{ .Values.dependencies.postgresql.depconfig.postgresqlDatabase }}` (xwiki) |
| JAVA_OPTS | `""` |
| DB_HOST | secretKeyRef `<release>-postgresqlcreds` key `plainhost` |
| DB_PASSWORD | secretKeyRef `<release>-postgresqlcreds` key `postgresql-password` |

## Probes
- None defined in values.yaml.

## Gotchas
- Chart runs as root with writable rootfs.
- Chart mounts only `/usr/local/xwiki`; upstream image also declares `VOLUME /usr/local/xwiki` (matches).
- Chart port 10208 maps to container 8080 (Tomcat); the upstream entrypoint/Tomcat listens on 8080.
