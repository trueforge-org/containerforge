# trueforge truecharts teslamate values.yaml

Source URL: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/teslamate/values.yaml (fetched 2026-11-26)

## Image
- Repository: `docker.io/teslamate/teslamate`
- Tag: `4.5.0@sha256:a285b02171a789cf2af5075502d2ec9034b58a42db777a30ae86aef2d0c12af4`
- PullPolicy: IfNotPresent

## Service
- Key `main`: http port 4000

## Persistence
- None defined.

## Env (container main)
| Var | Source |
| --- | --- |
| ENCRYPTION_KEY | secret `teslamate-secrets`, key `TESLAMATE_ENCRYPTION_KEY` |
| DATABASE_USER | templated, `teslamate` |
| DATABASE_PASS | secret `<release>-postgresqlcreds`, key `postgresql-password` |
| DATABASE_NAME | templated, `teslamate` |
| DATABASE_HOST | secret `<release>-postgresqlcreds`, key `plainhost` |
| DISABLE_MQTT | `true` |
| MQTT_HOST | "" |
| MQTT_PORT | 1883 |
| MQTT_USERNAME | "" |
| MQTT_PASSWORD | secret `env-secrets`, key `MQTT_PASSWORD` |

## Dependencies / other
- PostgreSQL dependency enabled (user and db `teslamate`); post-init SQL `ALTER USER teslamate WITH SUPERUSER`.
- Grafana datasource secret (`grafana_datasource: "1"`) pointing at Postgres port 5432, sslmode disabled.
- Workload: 1 replica, RollingUpdate.

## Security context
- readOnlyRootFilesystem: false; runAsUser: not set.
