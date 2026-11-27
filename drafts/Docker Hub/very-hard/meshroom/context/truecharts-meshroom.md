# TrueCharts chart: meshroom

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/meshroom/Chart.yaml (2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/meshroom/values.yaml (2026-11-27)

## What it is
- Chart `meshroom` v16.0.0, `appVersion: 2025.1.0`, category media, train stable.
- Description: free open-source 3D reconstruction software (AliceVision framework).
- Library dep: `common` 32.8.5 (oci://oci.trueforge.org/truecharts).
- kubeVersion `>=1.33.0-0`; Helm 3.14 to 4.1; Kubernetes max 1.35.0.

## Image
- `docker.io/alicevision/meshroom`
- tag `2025.1.0-av3.3.0-ubuntu22.04-cuda12.1.1@sha256:a53a5926e087409300cc6aaf32e4115d208e1f449fe83b3f52503d438132ef4b`
- pullPolicy IfNotPresent

## Ports
- service.main.ports.main: `port: 10243`, `targetPort: 22` (sshd, no protocol set).

## Volumes / paths
- persistence `data`: enabled, mountPath `/data`.

## Probes
- liveness, readiness, startup all `enabled: false`.

## Security context
- `readOnlyRootFilesystem: false`, `runAsNonRoot: false`, `runAsUser: 0`, `runAsGroup: 0`.

## Env vars
- None in values.yaml.

## Gotchas
- Chart exposes SSH (targetPort 22), not a web GUI. No HTTP probe.
- Image tag suffix encodes: Meshroom 2025.1.0, AliceVision av3.3.0, Ubuntu 22.04, CUDA 12.1.1.
