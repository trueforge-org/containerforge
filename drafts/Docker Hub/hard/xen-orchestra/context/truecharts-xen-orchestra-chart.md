# TrueCharts xen-orchestra chart (reference only)

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/xen-orchestra/Chart.yaml (fetched 2026-11-26)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/xen-orchestra/values.yaml (fetched 2026-11-26)
- Tree page https://github.com/trueforge-org/truecharts/tree/master/charts/stable/xen-orchestra not parsed (raw files used).

## What it is
- Helm chart `xen-orchestra`, chart version 14.0.0, appVersion `5.213.0`, category management, train stable.
- Depends on `common` 32.8.5 (oci://oci.trueforge.org/truecharts). kubeVersion `>=1.33.0-0`.

## Image (values.yaml)
- repository `docker.io/ronivay/xen-orchestra`
- tag `5.213.0@sha256:d059c8bb301e2f0c6c067d9af158e52c2fdd30f9b5df20b97fbeab9cbeb45aa8`

## Ports
- service main: protocol https, port 10324.

## Persistence
- `xo-data` -> `/var/lib/xo-server`
- `redis-data` -> `/var/lib/redis`

## Security context
- readOnlyRootFilesystem false, runAsNonRoot false, runAsUser 0, runAsGroup 0
- capabilities add `SYS_ADMIN`

## Probes
- liveness, readiness, startup: exec `/healthcheck.sh`

## Env
- `HTTPS_PORT` = service port (10324); `HTTP_PORT` = port + 1 (avoids binding 80); `REDIRECT_TO_HTTPS: true`.

## Gotchas
- Chart pins the upstream image's HTTPS mode (HTTPS_PORT set). The ContainerForge plan does not use HTTPS in v1.
- Chart sources list the ronivay image and TrueCharts tree.
