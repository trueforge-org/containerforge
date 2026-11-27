# TrueCharts chart: truecommand

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/truecommand/Chart.yaml (2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/truecommand/values.yaml (2026-11-27)

## What it is
- Chart `truecommand` v25.0.0, `appVersion: 3.3.0`, category Administration, train stable.
- Description: "Aggregated management of TrueNAS devices".
- Library dep: `common` 32.8.5 (oci://oci.trueforge.org/truecharts).
- kubeVersion `>=1.33.0-0`; Helm 3.14 to 4.1; Kubernetes max 1.35.0.

## Image
- `docker.io/ixsystems/truecommand`
- tag `3.3.0@sha256:35a6bb629397c70b4fa79426df5bdd548d5bc0c283bbf592e4394ba3b54c8761`
- pullPolicy IfNotPresent

## Ports
- service.main.ports.main: `port: 10031`, `targetPort: 80`.

## Volumes / paths
- persistence `data`: enabled, mountPath `/data`.

## Env vars
- None in values.yaml.

## Security context
- `readOnlyRootFilesystem: false`, `runAsNonRoot: false`, `runAsUser: 0`, `runAsGroup: 0`.

## Gotchas
- Chart runs root and sets no privileged flag; no probes configured in values.
