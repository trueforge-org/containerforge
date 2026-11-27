# TrueCharts mealie chart (stable)

Source URL(s) + date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/mealie/values.yaml (2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/mealie/Chart.yaml (2026-11-27)

## What it is
- Chart `mealie` version 29.0.0, appVersion 3.31.0, category utilities, train stable.
- Depends on `common` 32.8.5 (oci://oci.trueforge.org/truecharts) and postgresql (enabled, depconfig user/db `mealie`).

## Image
- repository: `ghcr.io/mealie-recipes/mealie`
- tag: `v3.31.0@sha256:97e21ac96e9a8d1ee15aaf558ba3f14998936b9d6f334e40ebb4c6c2127dc12f`
- pullPolicy: IfNotPresent

## Ports
| name | port | protocol |
| --- | --- | --- |
| main | 10018 | http |

Container port not set in values (upstream APP_PORT default 9000 per Dockerfile).

## Persistence
| name | enabled | type | mountPath | size |
| --- | --- | --- | --- | --- |
| data | true | default | /app/data | - |
| nltk | true | emptyDir | /nltk_data | 5Gi |

## Env (chart values, rendered as config)
- `envFrom` secretRefs: `frontend` and `api` (secrets built from values below).
- values under `mealie.frontend.theme.*` (light/dark colours), `mealie.api.general` (allow_signup true, default_group Home, base_url "", token_time 48), `mealie.api.security` (max_login_attempts 5, user_lockout_time 24), `mealie.api.smtp` (host/port 587/from_name Mealie/auth_strategy TLS), `mealie.api.webworkers` (workers_per_core 1, max_workers 1, web_concurrency 1), `mealie.api.ldap.*` (auth_enabled false), `mealie.api.oidc.*` (auth_enabled false, signup_enabled true, provider_name "OAuth", remember_me false).

## Other
- ingress integration homepage widget version 2.
- kubeVersion `>=1.33.0-0`.

## Gotchas
- Chart requires postgres; pgsql extra is installed in upstream image (`mealie[pgsql]`).
