# TrueCharts minecraft-router chart

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/minecraft-router/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/minecraft-router/Chart.yaml
- Fetched 2026-11-26

## What it is
TrueCharts Helm chart `minecraft-router` v5.1.0, appVersion 1.57.0. Wraps itzg/mc-router (Minecraft Java proxy by hostname) with Kubernetes service auto-discovery. Category minecraft. Depends on `common` 32.8.5.

## Runtime deps
- Image: `ghcr.io/itzg/mc-router`, tag `1.57.0@sha256:5ba123e0ddf45f5047d36f9f41f03f1429cb21cc6f1c20783105175a66f15ec1`, pullPolicy IfNotPresent.
- Kubernetes RBAC (clusterWide): `services` list/watch. Service account enabled, primary; `automountServiceAccountToken: true`.

## Entrypoint/flags
- Not set in chart (image entrypoint `/mc-router`).

## Env vars (chart values)
| Name | Value |
| --- | --- |
| API_BINDING | `:{{ service.api.port }}` (25564) |
| PORT | `{{ service.main.port }}` (25565) |
| IN_KUBE_CLUSTER | true (enables auto discovery) |
| DEFAULT | `{{ mcrouter.default }}` (default "") |
| MAPPING | `{{ join "," mcrouter.mappings }}` (default empty list) |
| KUBE_NAMESPACE | commented out (blank = all namespaces) |

## Ports
- service.main `main`: 25565 (Minecraft proxy).
- service.api `api`: 25564 (REST API, enabled).

## Probes
- liveness, readiness, startup: HTTP GET `/routes` on API port 25564, header `Accept: application/json`.

## Volumes/paths
- None in chart.

## User/UID
- No securityContext set in chart values.

## Version/asset naming
- Chart 5.1.0. Image `1.57.0` tag pinned by digest (matches appVersion).

## Gotchas
- Cluster-wide RBAC and automountServiceAccountToken are required for auto discovery.
- Chart value `mcrouter.mappings` is a list of `host:port` strings (e.g. `vanilla:25565`).
