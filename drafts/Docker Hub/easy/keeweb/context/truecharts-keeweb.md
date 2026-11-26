# TrueCharts chart: keeweb

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/keeweb (read via raw files)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/keeweb/Chart.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/keeweb/values.yaml
- Fetched 2026-11-26

## What it is
Chart `keeweb` version `11.0.0`, `appVersion: latest`, not deprecated. Category Productivity; keywords include keeweb, Tools-Utilities, Network-Web, Network-Management. Depends on `common` `32.8.5` from `oci://oci.trueforge.org/truecharts`. Kubernetes `>=1.33.0-0`.

## Container
- `docker.io/antelle/keeweb`, tag `latest@sha256:8ff5e10baa2ca50967964bf26af41461da79ef62a481094a00f75726623bcb36`, pullPolicy `IfNotPresent`.

## Security context
- container: `readOnlyRootFilesystem: false`, `runAsUser: 0`, `runAsGroup: 0`. No podSecurityContext.

## Env
- None present.

## Persistence
- `nginx` enabled, mountPath `/etc/nginx/external` (TLS cert directory).

## Service / ports
- `http` service enabled: port 8004 -> targetPort 80, protocol http.
- `main` ports: port 8003 -> targetPort 443, protocol https.

## Probes
- None present.

## Gotchas
- Chart exposes HTTPS on 443 via the upstream cert directory. ContainerForge plan serves HTTP on 8080 and drops the cert mount (plan section 9); design difference.
