# TrueCharts chart: mininote

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/mininote/values.yaml, .../Chart.yaml (fetched 2026-11-26)

## What it is
- Chart `mininote`, version 11.0.0, appVersion "latest"
- Description: simple, self-hosted, encrypted Markdown note-taking app (Vue 3 + Express)
- Depends on `common` 32.8.5 from oci://oci.trueforge.org/truecharts

## Image
- Repository: docker.io/n1try/mininote
- Tag: latest@sha256:da2c050fe79ffb5371d9c40a86cf2222d87e23958802bc9348455e8784afbc0d
- pullPolicy: IfNotPresent

## Ports
- Service main: port 3000 tcp -> targetPort 3000

## Env vars
- None set in values.yaml

## Volumes/paths
- data (enabled) mounted at /app/data

## Probes
- None set in values.yaml

## Security
- runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false; fsGroup not set

## Gotchas
- Chart runs as root with writable rootfs.
