# TrueCharts chart: apt-cacher-ng

**Source URL(s):** https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/apt-cacher-ng/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `apt-cacher-ng` v14.0.0, `appVersion: latest`, category `Network-Proxy`, train `stable`.
- Description: caching proxy for Linux distributor package files, primarily Debian/Debian-based.
- Library dependency: `common` 32.8.5 (`oci://oci.trueforge.org/truecharts`).
- Sources: `ghcr.io/sameersbn/apt-cacher-ng`, trueforge chart path, unix-ag.uni-kl.de acng page.
- kubeVersion `>=1.33.0-0`; helm min 3.14; max k8s 1.35.0.

## Image (values.yaml)
- Repository: `ghcr.io/sameersbn/apt-cacher-ng`
- Tag: `latest@sha256:82f55f9c8f627cee8ef5f710c1745388d79d3a3f2f3150353e6500021bec11b4`
- pullPolicy: IfNotPresent

## Security context (chart defaults)
- `readOnlyRootFilesystem: false`, `runAsNonRoot: false`, `runAsUser: 0`, `runAsGroup: 0`.

## Ports
| Name | Service port | Protocol | Target port |
| --- | --- | --- | --- |
| main | 3142 | tcp | 3142 |

## Probes
- Not set in values.yaml.

## Env
- None set by chart.

## Persistence
- `apt-cacher-ng`: enabled, mountPath `/var/cache/apt-cacher-ng`.

## Gotchas
- Chart runs as root and uses upstream cache path, not `/config`.
