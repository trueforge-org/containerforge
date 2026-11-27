# TrueCharts chart: mongo-express

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/mongo-express/Chart.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/mongo-express/values.yaml (fetched 2026-11-27)

## What it is
- Chart `mongo-express` version 14.0.0, appVersion `latest`, category database.
- Web MongoDB admin UI (Node.js, Express, Bootstrap 3).

## Image
- `public.ecr.aws/docker/library/mongo-express` tag `latest@sha256:1b23d7976f0210dbec74045c209e52fbb26d29b2e873d6c6fa3d3f0ae32c2a64`, pullPolicy IfNotPresent.

## Ports
- `service.main.ports.main`: port 18081, protocol http, targetPort 8081.

## Security context
- `readOnlyRootFilesystem: false` only (no runAs set).

## Probes
- liveness, readiness, startup: type http with `Authorization: Basic base64(ME_CONFIG_BASICAUTH_USERNAME:ME_CONFIG_BASICAUTH_PASSWORD)` header built by template. No `path` set in values.

## Env (main container)
| Name | Value in chart |
| --- | --- |
| ME_CONFIG_MONGODB_PORT | "" |
| ME_CONFIG_MONGODB_SERVER | "" |
| ME_CONFIG_BASICAUTH_USERNAME | "" |
| ME_CONFIG_BASICAUTH_PASSWORD | secretKeyRef `env-secrets` / `ME_CONFIG_BASICAUTH_PASSWORD` |
| ME_CONFIG_OPTIONS_EDITORTHEME | `default` |
| ME_CONFIG_MONGODB_AUTH_DATABASE | "" |
| ME_CONFIG_MONGODB_AUTH_USERNAME | "" |
| ME_CONFIG_MONGODB_AUTH_PASSWORD | secretKeyRef `<release>-mongodbcreds` / `mongodb-password` |

## Secret
- `secret.env-secrets` enabled, `ME_CONFIG_BASICAUTH_PASSWORD: ""`.

## Gotchas
- Chart does not set `ME_CONFIG_BASICAUTH_ENABLED`; upstream default is `false` (see github-mongo-express.md). Probe auth header is only meaningful if basic auth is enabled.
- Upstream health endpoint default is `/status` (`ME_CONFIG_HEALTH_CHECK_PATH`); chart probes do not set a path.
- `ME_CONFIG_MONGODB_SERVER` and `ME_CONFIG_MONGODB_PORT` are the chart's names; upstream uses `ME_CONFIG_MONGODB_URL` (default `mongodb://mongo:27017` in Dockerfile). Env names in chart are not in upstream README table.
- Chart port 18081 vs upstream listen 8081.
