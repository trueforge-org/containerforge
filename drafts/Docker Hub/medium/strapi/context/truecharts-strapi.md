# truecharts strapi (chart version 20.0.0, appVersion 5.57.0)

Source URL(s) + date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/strapi/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/strapi/Chart.yaml
- Fetched 2026-11-27

## What it is
- `name: strapi`, `appVersion: 5.57.0`, `version: 20.0.0`, `type: application`
- Description: "Open-source headless CMS. JavaScript, fully customizable and developer-first."
- Dependency: `common` 32.8.5 (`oci://oci.trueforge.org/truecharts`); `postgresql` enabled (depconfig user `strapi`, db `strapi`)
- Chart.yaml `sources` list not extracted in this pass (see the Chart.yaml file if needed)

## Image (values.yaml)
- repository: `docker.io/vshadbolt/strapi` (third-party image, not official Strapi)
- tag: `5.57.0-alpine@sha256:f9f0b0485d60c330382fb773d262fb0ef94d75db519c30ba8c7705c63efdfe0f`
- pullPolicy: Always

## Ports
| name | port |
| --- | --- |
| main | 1337 |

## Persistence
- `data`: enabled, mountPath `/srv/app`

## Env (workload.main container `main`)
| key | value |
| --- | --- |
| NPM_CONFIG_AUDIT | "false" |
| NPM_CONFIG_FUND | "false" |
| PORT | `{{ service port }}` (1337) |
| DATABASE_CLIENT | postgres |
| DATABASE_PORT | 5432 |
| DATABASE_NAME | `strapi` (from dependencies.postgresql.depconfig) |
| DATABASE_HOST | secretKeyRef `<Release>-postgresqlcreds` / `plainhost` |
| DATABASE_USERNAME | `strapi` |
| DATABASE_PASSWORD | secretKeyRef `<Release>-postgresqlcreds` / `postgresql-password` |
| NODE_ENV | development |
| STRAPI_DISABLE_UPDATE_NOTIFICATION | true |
| FAST_REFRESH | false |
| EXTRA_ARGS | "" |
| JWT_SECRET | secretKeyRef `env-secrets` / `JWT_SECRET` |
| ADMIN_JWT_SECRET | secretKeyRef `env-secrets` / `ADMIN_JWT_SECRET` |
| APP_KEYS | secretKeyRef `env-secrets` / `APP_KEYS` |

Secret `env-secrets` (chart defaults): JWT_SECRET `my_jwt_secret`, ADMIN_JWT_SECRET `my_admin_jwt_secret`, APP_KEYS `["keya", "keyb"]`.
Not set by chart: API_TOKEN_SALT, TRANSFER_TOKEN_SALT, ENCRYPTION_KEY.

## Resources
- requests cpu 1000m; limits cpu 4000m

## Security context
- readOnlyRootFilesystem false, runAsNonRoot false, runAsUser 0, runAsGroup 0

## Probes
- None set in values.yaml.

## Gotchas
- Chart runs the third-party image with NODE_ENV=development and FAST_REFRESH=false.
- Chart mounts the data volume at `/srv/app` (the naskio image project dir), not `/config`.
- Chart sets DATABASE_* for postgres, so the postgresql dependency is required for this chart.
