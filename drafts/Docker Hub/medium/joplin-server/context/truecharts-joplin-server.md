# TrueCharts joplin-server (chart 24.0.0)

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/joplin-server/values.yaml (2026-11-26)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/joplin-server/Chart.yaml (2026-11-26)

## What it is
Helm chart for Joplin Server (sync server). Chart `version: 24.0.0`, `appVersion: 3.7.6`, `kubeVersion: '>=1.33.0-0'`, `type: application`, category `media`, train `stable`.
Library dependency: `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`.

## Image
- `docker.io/joplin/server`, tag `3.7.6@sha256:1cd9097ec3f788ba9813b7907dd8d525c834b93c725da1add189bfd08f746cf0` (digest = manifest list digest, matches Docker Hub `3.7.6`/`latest`).
- `pullPolicy: IfNotPresent`

## Runtime deps
- PostgreSQL subchart: `dependencies.postgresql.enabled: true`, `depconfig.postgresqlUsername: joplin`, `postgresqlDatabase: joplin`.

## Env vars (container `main`)
| Name | Value in chart |
| --- | --- |
| APP_BASE_URL | "" (user-supplied; used in probe Host header) |
| APP_PORT | `{{ service.main.ports.main.port }}` = 22300 |
| DB_CLIENT | `pg` |
| POSTGRES_DATABASE | `joplin` (from depconfig) |
| POSTGRES_USER | `joplin` (from depconfig) |
| POSTGRES_PORT | `5432` |
| POSTGRES_PASSWORD | secret `<release>-postgresqlcreds` key `postgresql-password` |
| POSTGRES_HOST | secret `<release>-postgresqlcreds` key `plainhost` |
| MAILER_ENABLED | `0` |
| MAILER_HOST | "" |
| MAILER_PORT | `465` |
| MAILER_SECURITY | `tls` |
| MAILER_AUTH_USER | "" |
| MAILER_AUTH_PASSWORD | secret `env-secrets` key `MAILER_AUTH_PASSWORD` |
| MAILER_NOREPLY_NAME | "" |
| MAILER_NOREPLY_EMAIL | "" |

## Ports
- service `main` / port `main`: 22300.

## Probes
- liveness and readiness: HTTP GET `/api/ping` on port 22300, Host header = APP_BASE_URL with scheme stripped.
- startup: TCP 22300.

## Volumes/paths
- persistence `config` enabled, `mountPath: /config`.

## User/UID
- Chart sets `securityContext.container`: `runAsNonRoot: false`, `runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`.
- Note: upstream image sets `USER joplin` (Dockerfile.server). The chart overrides to root.

## Config files
- None in chart beyond env. Secret `env-secrets` created with empty `MAILER_AUTH_PASSWORD`.

## Gotchas
- Chart pins image 3.7.6 while upstream latest release is 3.7.24 (see README of this context dir).
- No `/config` reference seen in the upstream `Dockerfile.server` text fetched; `/config` is a chart-side mount only (UNVERIFIED at runtime).
- Chart's probe Host header depends on `APP_BASE_URL`; empty value yields an empty Host.
