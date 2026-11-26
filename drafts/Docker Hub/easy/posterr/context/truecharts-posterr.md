# TrueCharts chart: posterr

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/posterr (tree page, not fetched directly)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/posterr/values.yaml (fetched 2026-11-26)

## What it is
TrueCharts Helm chart for posterr. Values only fetched; the chart is a Kubernetes packaging, not the container itself.

## Image
- repository: `docker.io/petersem/posterr`
- tag: `latest@sha256:292ebe1cb686d326b3014f1a85cbc6e0c5ef4eb4a8501470a0fd775e696b4d26`, pullPolicy IfNotPresent.

## Ports
- Service `main`, port `main`: port 9876 (http), targetPort 3000.

## Volumes/paths
- `config` mountPath `/usr/src/app/config` (enabled).
- `custom` mountPath `/usr/src/app/public/custom` (enabled).

## User/UID & permissions
- Container securityContext: runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false.
- No podSecurityContext, env vars or probes set in values.

## Gotchas
- Chart expects root and writable rootfs; ContainerForge plan intends non-root with read-only rootfs handling, which is independent of this chart.
