# TrueCharts chart: xteve

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/xteve/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- TrueCharts chart for `ghcr.io/k8s-at-home/xteve` (M3U proxy for Plex DVR / Emby Live TV).
- Chart `version: 19.0.0`, `appVersion: 2.2.0.200`, category media, train stable.

## Runtime deps
- Helm library `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`.
- kubeVersion `>=1.33.0-0`; max helm 4.1; min helm 3.14.

## Image
- `repository: ghcr.io/k8s-at-home/xteve`, `tag: v2.2.0.200@sha256:292b3614...`, pullPolicy IfNotPresent.

## Ports
| Service | Port | Target |
| --- | --- | --- |
| main | 34400 | 34400 |

## Volumes/paths
| Persistence | Mount | Note |
| --- | --- | --- |
| config | /config | enabled |

## Env vars, probes, secrets
- None defined in values.yaml. No probes defined.

## User/UID
- No runAsUser set in chart (securityContext only sets `readOnlyRootFilesystem: false`).

## Gotchas
- Image is from `k8s-at-home` namespace (repo `k8s-at-home/container-images` listed as source).
- Chart pins v2.2.0.200 image tag; xTeVe-Downloads info.json reports version 2.2.0.0200 (same release, different format).
