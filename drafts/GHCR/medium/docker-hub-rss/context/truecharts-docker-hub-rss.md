# TrueCharts docker-hub-rss chart

Source URL(s) + date:
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/docker-hub-rss/Chart.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/docker-hub-rss/values.yaml
- Fetched 2026-11-27

## What it is
- Chart `docker-hub-rss` v11.0.0, appVersion `latest`, type application, category Cloud.
- Description: RSS feed for Chart Hub images.
- Depends on `common` 32.8.5 (oci://oci.trueforge.org/truecharts).
- kubeVersion `>=1.33.0-0`; min helm 3.14; max helm 4.1; max k8s 1.35.0.
- Keywords: docker-hub-rss, Cloud, Tools-Utilities, Network-Web.
- Chart sources: `ghcr.io/theconnman/docker-hub-rss`, github.com/TheConnMan/docker-hub-rss.

## Image (values.yaml)
| Key | Value |
| --- | --- |
| repository | `ghcr.io/theconnman/docker-hub-rss` |
| tag | `latest@sha256:38eba84b2be8ad3497604def130f0e5d7d5925534727168aad67790e2ec9da25` |
| pullPolicy | IfNotPresent |

## Env
- None set in chart values.

## Persistence
- `persistence: {}` (none).

## Ports
- Service `main` disabled; port `main` disabled. Chart declares no port.

## Security context
- runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.

## Probes
- liveness, readiness, startup all disabled.

## Gotchas
- Chart runs as root with writable rootfs (not read-only compatible as shipped).
- Image pinned by digest with `latest` tag.
- No service and no port in the chart, unlike the upstream `EXPOSE 3000`.
