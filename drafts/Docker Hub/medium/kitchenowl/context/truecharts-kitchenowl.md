# TrueCharts kitchenowl (chart 16.0.0)

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/kitchenowl/values.yaml (2026-11-26; fetched in two parts, same file)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/kitchenowl/Chart.yaml (2026-11-26)

## What it is
- Chart `version: 16.0.0`, `appVersion: 0.8.1`, `kubeVersion: '>=1.33.0-0'`, category `utilities`, train `stable`.
- Description: "KitchenOwl is a smart self-hosted grocery list and recipe manager."
- Library dep: `common` 32.8.5 (`oci://oci.trueforge.org/truecharts`).
- Two-container pod: frontend (web) + main (backend).

## Images
| Role | Image | Tag |
| --- | --- | --- |
| frontend (`image`) | `docker.io/tombursch/kitchenowl-web` | `v0.8.1@sha256:a2093eb32dfe501d6d9ce068ee5645654b806772a76138ab51b20c213bddf63a` |
| backend (`backendImage`) | `docker.io/tombursch/kitchenowl` | `v0.8.1@sha256:6a048135399691da25aec04ea107666cb7ce8eb46f5fed9a46a5ac254fe23073` |
- `pullPolicy: IfNotPresent` on both.

## Services / ports
| Service | Target pod | Port | targetPort | Protocol |
| --- | --- | --- | --- | --- |
| main | frontend (container `frontend`) | 10246 | 80 | http |
| backend | main (container `main`) | 10247 | 5000 | http |

## Backend env (container `main`)
| Name | Value |
| --- | --- |
| FRONT_URL | "" |
| OIDC_ISSUER | "" |
| OIDC_CLIENT_ID | "" |
| OIDC_CLIENT_SECRET | secret `env-secrets` key `OIDC_CLIENT_SECRET` |
| APPLE_CLIENT_ID | "" |
| APPLE_CLIENT_SECRET | secret `env-secrets` key `APPLE_CLIENT_SECRET` |
| GOOGLE_CLIENT_ID | "" |
| GOOGLE_CLIENT_SECRET | secret `env-secrets` key `GOOGLE_CLIENT_SECRET` |
| JWT_SECRET_KEY | secret `kitchenowl-secrets` key `JWT_SECRET_KEY` (chart comment: must change) |
| STORAGE_PATH | `/data` (from persistence mountPath) |
| DB_DRIVER | `postgresql` |
| DB_HOST | secret `<release>-postgresqlcreds` key `plainhost` |
| DB_NAME | `kitchenowl` (depconfig) |
| DB_USER | `kitchenowl` (depconfig) |
| DB_PASSWORD | secret `<release>-postgresqlcreds` key `postgresql-password` |

## Frontend env (container `frontend`)
| Name | Value |
| --- | --- |
| BACK_URL | `<fullname>-backend:<backend port 10247>` |

## Probes
- Backend `main`: liveness/readiness `exec` `uwsgi_curl localhost:5000 /api/health/8M4F88S8ooi4sMbLBfkkV7ctWwgibW6V`; startup TCP 5000.
- Frontend: liveness/readiness HTTP `/` on 80; startup TCP 80.

## Volumes/paths
| Persistence | Mount |
| --- | --- |
| data (main container) | `/data` |
| nginx-conf (emptyDir, frontend) | `/etc/nginx/conf.d` |

## Runtime deps
- PostgreSQL subchart: `dependencies.postgresql.enabled: true`, user `kitchenowl`, db `kitchenowl`.

## User/UID
- Not set in chart values (no securityContext block seen in fetched text).

## Gotchas
- Chart target ports: backend 5000 (uwsgi socket), frontend 80. Upstream backend `wsgi.ini` also binds HTTP 8080 in `[web]` (see github-kitchenowl-backend-dockerfile.md).
- Chart `jwtSecretKey` default is a placeholder; upstream backend Dockerfile sets `JWT_SECRET_KEY='PLEASE_CHANGE_ME'`.
