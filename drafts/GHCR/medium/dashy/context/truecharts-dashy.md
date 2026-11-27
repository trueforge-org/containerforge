# TrueCharts dashy chart

Source URL(s) + date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/dashy/Chart.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/dashy/values.yaml
- Fetched 2026-11-27

## What it is
- Chart `dashy` v13.0.1, appVersion `latest`, type application, category dashboard.
- Description: organise self-hosted services from a single place.
- Depends on `common` 32.8.5 (oci://oci.trueforge.org/truecharts).
- kubeVersion `>=1.33.0-0`; min helm 3.14; max helm 4.1; max k8s 1.35.0.
- Chart sources: `ghcr.io/lissy93/dashy`, github.com/Lissy93/dashy.

## Image (values.yaml)
| Key | Value |
| --- | --- |
| repository | `ghcr.io/lissy93/dashy` |
| tag | `latest@sha256:f998e7959e338bf29e74d0a24a5d30ad0e98568dffb43af0ce24fd9b9c4c958d` |
| pullPolicy | IfNotPresent |

## Env (workload.main.podSpec.containers.main.env)
| Name | Value |
| --- | --- |
| NODE_ENV | `production` |

## Ports
- Service `main`, port `main`: `port: 10310`, `protocol: http`, `targetPort: 8080`.

## Persistence
| Name | Mount path |
| --- | --- |
| icons | `/app/public/item-icons` (enabled) |

## Dashy config (chart)
- `dashy.enabled: false`; `configDirectoryHostPath: ""`; `configDirectoryHostReadOnly: true`.
- `dashyConfig: {}` (empty; leave empty when using a host config directory).

## Security context
- runAsNonRoot false, runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.

## Resources
- Limits cpu 2000m, memory 3000Mi. Requests cpu 200m, memory 500Mi.

## Probes
- liveness, readiness, startup all `type: exec`, command `node /app/services/healthcheck`.

## Gotchas
- Chart runs as root with writable rootfs (not read-only compatible as shipped).
- Image pinned by digest with `latest` tag.
- Icon persistence path is `/app/public/item-icons`.
