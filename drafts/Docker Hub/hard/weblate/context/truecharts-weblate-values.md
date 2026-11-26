# trueforge truecharts weblate values.yaml

Source URL: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/weblate/values.yaml (fetched 2026-11-26)
Also seen: https://github.com/trueforge-org/truecharts/tree/master/charts/stable/weblate (directory listing; content from raw values.yaml)

## Image
- Repository: `docker.io/weblate/weblate`
- Tag: `4.16.4-1@sha256:6614e1ad2a02e871c812b536b32ce8d91cf01582b1e6888ddee81d75958585e0`
- PullPolicy: IfNotPresent

## Service
- `main`: TCP 10158 -> 8080

## Persistence
- `config` -> `/app/data`
- `cache` emptyDir -> `/app/cache`

## Env (container main)
| Var | Value |
| --- | --- |
| WEBLATE_TIME_ZONE | templated from `.Values.TZ` |
| POSTGRES_USER | templated, default `weblate` |
| POSTGRES_DATABASE | templated, default `weblate` |
| POSTGRES_PORT | 5432 |
| POSTGRES_PASSWORD | secret `<release>-postgresqlcreds`, key `postgresql-password` |
| POSTGRES_HOST | secret `<release>-postgresqlcreds`, key `plainhost` |
| REDIS_PORT | 6379 |
| REDIS_DB | "0" |
| REDIS_HOST | secret `<release>-valkeycreds`, key `plainhost` |
| REDIS_PASSWORD | secret valkey, key `valkey-password` |
| WEBLATE_SITE_TITLE | "My Project's Weblate" |
| WEBLATE_SITE_DOMAIN | "weblate.example.com" |

- envFrom: configMap `weblate-env`. Other weblate options commented out or empty.

## Dependencies
- valkey and postgresql enabled.

## Security context
- Container: readOnlyRootFilesystem false; runAsUser 1000; runAsGroup 0. Pod fsGroup 1000.

## Probes
- liveness, readiness, startup all `/healthz`.

## Resources
- limits cpu 2000m, memory 3000Mi; requests cpu 200m, memory 500Mi.
