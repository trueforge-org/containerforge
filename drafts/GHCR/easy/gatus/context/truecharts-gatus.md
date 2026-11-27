# TrueCharts chart: gatus

Source URL(s):
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/gatus/values.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/gatus/Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `gatus` version 6.0.0, appVersion 5.38.0, train stable.
- Description: automated service health dashboard.
- Chart sources: `ghcr.io/home-operations/gatus-sidecar`, `ghcr.io/twin/gatus`, https://github.com/TwiN/gatus, https://github.com/home-operations/gatus-sidecar.
- Dependency: postgresql (enabled by default in the chart).

## Images
| Key | Value |
| --- | --- |
| image.repository | `ghcr.io/twin/gatus` (GHCR) |
| image.tag | `v5.38.0@sha256:085ed63da963728965d00a3c78aa6167e3bf135218485b893201758e079e8415` |
| sidecarImage.repository | `ghcr.io/home-operations/gatus-sidecar` |
| sidecarImage.tag | `0.6.1@sha256:c2b24374a8a4c5551c0122f3a7ae383ff65a0ea0bcd3b541530db84490fea2af` |

## Sidecar (chart values, disabled by default)
- `sidecar.enable: false`. Namespace, ingressClass, gatewayName empty.
- Sidecar args: `--output=/config/gatus-sidecar.yaml`, `--enable-service`, `--enable-ingress`, `--enable-httproute`, `--auto-service`, `--auto-ingress`, `--auto-httproute`, `--namespace`, `--ingress-class`, `--gateway-name` (driven by values).
- Sidecar probes: liveness, readiness, startup on the main service port 8080.
- RBAC (when sidecar enabled): cluster-wide get/list/watch on services, ingresses, ingressclasses, httproutes, gateways.

## Gatus main runtime env
| Name | Value |
| --- | --- |
| GATUS_CONFIG_PATH | `/config` (from persistence.configmain.mountPath) |
| GATUS_DELAY_START_SECONDS | 10 |

## Ports
| Name | Port | targetPort |
| --- | --- | --- |
| main | 8080 | 8080 |

## Volumes
| Persistence | mountPath | Notes |
| --- | --- | --- |
| configmain | /config | enabled when sidecar.enable; shared config dir |
| config | /config/config.yaml | configmap `config` key `config.yaml`, subPath, readOnly |

## Chart config.yaml (configmap)
- `metrics: true`; one example endpoint `example` (https://example.org, 60s, conditions `[STATUS] == 200` and body pattern).
- When postgres enabled: `storage.type: postgres`, path `${GATUS_DB_URL}?client_encoding=utf8`.

## Security context
- pod sysctl `net.ipv4.ping_group_range` = `0 2147483647` (needed for ICMP ping from non-root).

## Probes
- Main container probes: not set in the chart beyond defaults; sidecar probes as above.

## Metrics
- metrics.main enabled, path `/metrics`, port `main`.

## Gotchas
- Config path is a directory (`GATUS_CONFIG_PATH=/config`) when the sidecar is on, so Gatus merges `*.yaml` files in it.
- The config.yaml configmap mounts as a single file at `/config/config.yaml` (readOnly).
- Postgres is a chart dependency; `GATUS_DB_URL` is expected from the postgres secret.
