# TrueCharts chart: gatus

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/gatus/values.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/gatus/Chart.yaml (fetched 2026-11-27)

## What it is
- Chart for Gatus (service health monitoring). Optional sidecar for Kubernetes service/ingress/httproute discovery (`sidecar.enable: false` by default).

## Image
- `ghcr.io/twin/gatus` tag `v5.38.0@sha256:085ed63da963728965d00a3c78aa6167e3bf135218485b893201758e079e8415`, `pullPolicy: IfNotPresent`.
- Sidecar image (optional): `ghcr.io/home-operations/gatus-sidecar` tag `0.6.1@sha256:c2b24374a8a4c5551c0122f3a7ae383ff65a0ea0bcd3b541530db84490fea2af`.

## Env vars (chart)
| Name | Chart value |
| --- | --- |
| GATUS_CONFIG_PATH | `/config` (persistence.configmain.mountPath) |
| GATUS_DELAY_START_SECONDS | `10` |

- Postgres storage (when `dependencies.postgresql.enabled: true`) is set in the configmap, not env: `storage.type: postgres`, `path: "${GATUS_DB_URL}?client_encoding=utf8"`.

## Ports
- Service `main`: port 8080, targetPort 8080.

## Volumes/paths
- `configmain` -> `/config` (only when sidecar enabled, `targetSelectAll`, readOnly false).
- `config` configmap `config` -> `/config/config.yaml` (subPath `config.yaml`, readOnly true).

## Config files
- configmap `config`, key `config.yaml`: `metrics: true`, one example endpoint (`https://example.org`, interval 60s, conditions `[STATUS] == 200` and body pattern), plus postgres storage block when enabled.
- Sidecar writes `/config/gatus-sidecar.yaml` (args `--output=/config/gatus-sidecar.yaml`).

## Dependencies
- PostgreSQL (`dependencies.postgresql.enabled: true`), user/db `gatus`.

## Security/sysctls
- Pod sysctl `net.ipv4.ping_group_range` = `0 2147483647`.

## User/UID
- Chart does not set runAsUser here. Upstream image has no USER (scratch base).

## Healthcheck
- Sidecar probes (only if sidecar enabled): liveness/readiness/startup on service port 8080.
- Main container: no explicit probes in values.

## Gotchas
- Sidecar RBAC is cluster-wide (`rbac.main.clusterWide: true`) and enabled only with `sidecar.enable`.
- Config path default in image is empty (`GATUS_CONFIG_PATH=""`); chart sets `/config`.
