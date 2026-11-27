# TrueCharts chart: agregarr

**Source URL(s):** https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/agregarr/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `agregarr` v5.0.0, `appVersion: 2.4.2`, category `media`, train `stable`.
- Description: "Home and Collection manager for Plex."
- Library dependency: `common` 32.8.5 (`oci://oci.trueforge.org/truecharts`).
- Sources: `ghcr.io/agregarr/agregarr`, github agregarr/agregarr, trueforge chart path.
- kubeVersion `>=1.33.0-0`; helm min 3.14; max k8s 1.35.0.

## Image (values.yaml)
- Repository: `ghcr.io/agregarr/agregarr`
- Tag: `v2.4.2@sha256:5f1390bc43fefbbfb67f38a7a8dd65b4086c1f187a37c8df5c6020a498e5d1b5`
- pullPolicy: IfNotPresent

## Security context (chart defaults)
- `readOnlyRootFilesystem: false`, `runAsNonRoot: false`, `runAsUser: 0`, `runAsGroup: 0`.

## Ports
| Name | Service port | Protocol | Target port |
| --- | --- | --- | --- |
| main | 7171 | http | 7171 |

## Probes
- Not set in values.yaml (chart defaults apply).

## Env
- None set by chart.

## Persistence
- `config`: enabled, mountPath `/app/config`.

## Gotchas
- Chart mounts `/app/config` (upstream data path), not `/config`.
- Runs as root with writable rootfs; not the ContainerForge model.
