# TrueCharts miniflux chart

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/miniflux/Chart.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/miniflux/values.yaml
- Fetched 2026-11-26

## What it is
TrueCharts Helm chart `miniflux` v20.0.0, appVersion 2.3.5. Minimalist RSS feed reader. Category rss. Depends on `common` 32.8.5 and `postgresql` subchart (enabled, user/db `miniflux`).

## Runtime deps
- Image: `ghcr.io/miniflux/miniflux`, tag `2.3.5@sha256:8fd6c3c434ecc3d4083306f83e03c0bb74c632e0f8378da5ead7e1773b0b89c9`, pullPolicy IfNotPresent.
- PostgreSQL (subchart).

## Entrypoint/flags
- Not set in chart (image CMD `/usr/bin/miniflux`).

## Env vars (chart values)
| Name | Value |
| --- | --- |
| CREATE_ADMIN | 1 |
| RUN_MIGRATIONS | 1 |
| ADMIN_USERNAME | admin |
| ADMIN_PASSWORD | secretKeyRef env-secrets/ADMIN_PASSWORD (chart default "changeme"; not recorded) |
| DATABASE_URL | secretKeyRef `{{Release.Name}}-postgresqlcreds`/url |

## Ports
- service.main `main`: port 10091 -> targetPort 8080 (container listens on 8080).

## Volumes/paths
- persistence.config: mountPath `/config` (enabled). Miniflux itself needs no volume per upstream docs.

## User/UID
- No securityContext set in chart values.

## Healthcheck/probes
- liveness: HTTP `/healthcheck` on port 8080, initialDelaySeconds 30, periodSeconds 10, failureThreshold 3, timeoutSeconds 1.
- readiness/startup: not set.

## Version/asset naming
- Chart 20.0.0. Image 2.3.5 pinned by digest.

## Gotchas
- Chart sets `ADMIN_PASSWORD` default "changeme" in the secret; override for real use.
- Upstream compose healthcheck uses `/usr/bin/miniflux -healthcheck auto` (see miniflux-docs.md).
