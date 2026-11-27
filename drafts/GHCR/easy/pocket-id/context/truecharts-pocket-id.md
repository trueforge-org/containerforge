# TrueCharts pocket-id chart

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/pocket-id/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/pocket-id/Chart.yaml
- Fetched 2026-11-27

## What it is
- "Pocket ID is a simple OIDC provider that supports passkeys and LDAP." Chart 3.0.0, appVersion 2.19.3, keywords auth/oidc
- Dependency: `common` 32.8.5 (oci://oci.trueforge.org/truecharts)
- Chart sources: ghcr.io/pocket-id/pocket-id, github pocket-id/pocket-id

## Image (values.yaml)
- repository: `ghcr.io/pocket-id/pocket-id` (GHCR, no Docker Hub source)
- tag: `v2.19.3@sha256:189e03bb73bb86d7108fe81cbe2237c408cff2176b14cd7a39cc12a2ee8b2762`

## Service
| Service | Port | Proto | Target |
| --- | --- | --- | --- |
| main | 1411 | http | 1411 |

## Probes (main)
- liveness, readiness, startup: HTTP GET `/healthz`

## Env (workload.main container)
| Name | Value in chart |
| --- | --- |
| APP_URL | "https://your-pocket-id-domain.com" (placeholder) |
| TRUST_PROXY | "true" |
| ANALYTICS_DISABLED | "true" |
| VERSION_CHECK_DISABLED | "false" |
| MAXMIND_LICENSE_KEY | secretKeyRef env-secrets/MAXMIND_LICENSE_KEY |
| ENCRYPTION_KEY | secretKeyRef env-secrets/ENCRYPTION_KEY |
| DB_CONNECTION_STRING | "file:data/pocket-id.db" |

## Secrets
- secret `env-secrets` (enabled): MAXMIND_LICENSE_KEY "", ENCRYPTION_KEY "changeme_changeme!!" (placeholder value in chart)

## Persistence
| Name | Mount |
| --- | --- |
| data | /app/data |

## Gotchas
- Chart ships a placeholder ENCRYPTION_KEY and APP_URL; both must be overridden.
- DB default is SQLite under /app/data (`file:data/pocket-id.db`, relative to /app).
