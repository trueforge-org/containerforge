# TrueCharts chart: quassel-core

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/quassel-core/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `quassel-core` version 17.0.0, appVersion 0.14.0, train stable, category `incubator`.
- Description: "Quassel-core is a modern, cross-platform, distributed IRC client."
- Dependency: `common` 32.8.5 (`oci://oci.trueforge.org/truecharts`); kubeVersion `>=1.33.0-0`.
- Chart sources: ghcr.io/linuxserver/quassel-core, chart tree in trueforge repo.

## Image (values.yaml)
| Key | Value |
| --- | --- |
| repository | `ghcr.io/linuxserver/quassel-core` |
| tag | `0.14.0@sha256:cefb9aa752d4db099d98be5966432e9dcd298695571c8eedc84ffc298f3258e0` |
| pullPolicy | IfNotPresent |

## Ports
| Name | port | targetPort |
| --- | --- | --- |
| main | 4242 | 4242 |
| ident (enabled) | 10113 | 10113 |

## Persistence
- `varrun` enabled (no mountPath in values). No /config mount declared in values.yaml.

## Dependencies (chart-level)
- `postgresql` enabled, CNPG-style depconfig: user `quassel-core`, database `quassel-core`.

## Workload env (main container)
| Env | Value |
| --- | --- |
| DB_BACKEND | `PostgreSQL` |
| DB_PGSQL_USERNAME | `{{ .Values.dependencies.postgresql.depconfig.postgresqlUsername }}` (quassel-core) |
| DB_PGSQL_DATABASE | `{{ .Values.dependencies.postgresql.depconfig.postgresqlDatabase }}` (quassel-core) |
| DB_PGSQL_PORT | 5432 |
| DB_PGSQL_PASSWORD | secretKeyRef `<release>-postgresqlcreds` key `postgresql-password` |
| DB_PGSQL_HOSTNAME | secretKeyRef `<release>-postgresqlcreds` key `plainhost` |
| AUTH_AUTHENTICATOR | `Database` |
| RUN_OPTS | `--config-from-environment` |

## Probes
- liveness, readiness, startup: all `tcp`.

## Security context (chart)
- runAsNonRoot false, readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0.

## Gotchas
- Chart runs the image as root and uses PostgreSQL in stateless env mode. ContainerForge plan defaults to SQLite (see plan.md).
