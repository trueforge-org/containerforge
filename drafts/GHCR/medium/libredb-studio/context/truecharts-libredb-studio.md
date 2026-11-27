# TrueCharts chart: libredb-studio

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/libredb-studio/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- "LibreDB Studio is a self-hosted database client for SQL and NoSQL engines that runs in a browser tab." Chart 4.0.0, `appVersion 1.3.0`. Category Tools-Utilities.
- Dependency `common` 32.8.5 (oci://oci.trueforge.org/truecharts).
- Sources: ghcr.io/libredb/libredb-studio, github.com/libredb/libredb-studio (incl. pkgs/container page).

## Image
- Repository `ghcr.io/libredb/libredb-studio`
- Tag `1.3.0@sha256:3521f28fc2732a040715015669dfb475a1f2bc60b31025cb58ef472379ca74c7`, pullPolicy IfNotPresent.

## Ports
| Name | Port | Target | Protocol |
| --- | --- | --- | --- |
| main | 10540 | 3000 | http |

## Env vars (chart)
| Name | Value |
| --- | --- |
| PORT | `{{ service.main.ports.main.targetPort }}` (3000) |
| STORAGE_PROVIDER | sqlite |
| STORAGE_SQLITE_PATH | /app/data/libredb-storage.db |
| ADMIN_EMAIL | admin@libredb.org |
| AUTH_COOKIE_SECURE | "false" (chart comment: set "true" when TLS terminates at ingress/LB) |

- No JWT_SECRET / ADMIN_PASSWORD set in chart (upstream auto-generates on first run).

## Probes
- liveness, readiness, startup: HTTP `/api/db/health`.

## Persistence
| Name | Mount |
| --- | --- |
| data | `/app/data` |

## Gotchas
- Chart keeps SQLite under `/app/data` (the upstream volume path).
