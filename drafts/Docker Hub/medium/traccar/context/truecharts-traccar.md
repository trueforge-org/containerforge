# truecharts traccar (chart version 23.0.0, appVersion 6.17.0)

Source URL(s) + date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/traccar/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/traccar/Chart.yaml
- Fetched 2026-11-27

## What it is
- `name: traccar`, `appVersion: 6.17.0`, `version: 23.0.0`, `type: application`
- Description: "Traccar is an open source GPS tracking system."

## Image (values.yaml)
- repository: `docker.io/traccar/traccar`
- tag: `6.17@sha256:b32d9346adf46df7c33c58577e17ad60f6feadd1f3cd87c876041f6c79317ef1`
- pullPolicy: IfNotPresent

## Ports
| name | port | targetPort |
| --- | --- | --- |
| main | 8082 | 8082 |

Only the web port is exposed by the chart. No device/protocol ports are listed.

## Persistence
- `data`: enabled, mountPath `/opt/traccar/data`

## Dependencies
- `postgresql` enabled; depconfig user `traccar`, database `traccar`

## Env (workload.main container `main`)
| key | value |
| --- | --- |
| CONFIG_USE_ENVIRONMENT_VARIABLES | true |
| LOGGER_CONSOLE | true |
| DATABASE_DRIVER | `org.postgresql.Driver` |
| DATABASE_USER | `traccar` (from dependency) |
| DATABASE_PASSWORD | secretKeyRef `<Release>-postgresqlcreds` / `postgresql-password` |
| DATABASE_URL | secretKeyRef `<Release>-postgresqlcreds` / `jdbc` |

## Security context
- runAsNonRoot false, readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0

## Probes
- None set in values.yaml.

## Gotchas
- Chart sets `CONFIG_USE_ENVIRONMENT_VARIABLES=true`, so DB settings come from env (see traccar-docs.md for the env override rule).
- Chart mounts only `/opt/traccar/data`; the docs recommend also mounting logs and conf (see traccar-docs.md).
