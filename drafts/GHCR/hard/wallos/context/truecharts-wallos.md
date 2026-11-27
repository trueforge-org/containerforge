# TrueCharts chart: wallos

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/wallos/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- TrueCharts chart for `ghcr.io/ellite/wallos` (self-hosted subscription tracker, PHP app).
- Chart `version: 13.0.0`, `appVersion: 5.11.3`, category media, train stable.

## Runtime deps
- Helm library `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`.
- kubeVersion `>=1.33.0-0`; max helm 4.1; min helm 3.14.

## Image
- `repository: ghcr.io/ellite/wallos`, `tag: 5.11.3@sha256:84c3b218...`, pullPolicy IfNotPresent.

## Ports
| Service | Port | Target | Protocol |
| --- | --- | --- | --- |
| main | 8282 | 80 | tcp |

## Volumes/paths
| Persistence | Mount | Note |
| --- | --- | --- |
| database | /var/www/html/db | enabled |
| logos | /var/www/html/images/uploads/logos | enabled |

## User/UID
- `runAsNonRoot: false`, `runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`.

## Env vars, probes
- No env vars, probes, or secrets defined in values.yaml.

## Gotchas
- Chart runs as root with writable rootfs.
- Chart pins 5.11.3; plan Dockerfile reference is tag v5.11.2 (both Dockerfiles identical, see upstream file).
