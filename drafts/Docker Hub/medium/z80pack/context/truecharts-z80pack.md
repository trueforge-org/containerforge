# TrueCharts chart: z80pack

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/z80pack/Chart.yaml (2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/z80pack/values.yaml (2026-11-27)

## What it is
- Chart `z80pack` v11.0.0, `appVersion: latest`, train stable, category Other.
- Description: CP/M 1/2/3 and MP/M II emulator, command-line chart with shell-in-a-box web terminal.
- Library dep: `common` 32.8.5 (oci://oci.trueforge.org/truecharts).
- kubeVersion `>=1.33.0-0`; Helm 3.14 to 4.1; Kubernetes max 1.35.0.

## Image
- `docker.io/dlandon/z80pack`, tag `latest@sha256:c1287d3b1258a21c1049a8d353834b9d0f40f4a87f13b9b1f8383b79436da831`
- pullPolicy IfNotPresent

## Env vars
- None set in values.yaml.

## Ports
- service.main.ports.main: 4200/tcp (port and targetPort 4200).

## Volumes / paths
- persistence `config`: enabled, mountPath `/config`.

## Security context
- `readOnlyRootFilesystem: false`, `runAsUser: 0`, `runAsGroup: 0`.

## Gotchas
- No env, no secrets; config is only the `/config` mount.
- Chart `appVersion` is `latest`; the pinned image digest is the only version signal.
