# TrueCharts chart: tubesync

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/tubesync/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- TrueCharts chart for `ghcr.io/meeb/tubesync` (YouTube PVR, web UI).
- Chart `version: 11.0.1`, `appVersion: latest`, category Downloaders, train stable.

## Runtime deps
- Helm library `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`.
- kubeVersion `>=1.33.0-0`; max helm 4.1; min helm 3.14.

## Image
- `repository: ghcr.io/meeb/tubesync`, `tag: latest@sha256:cd8a771a...`, pullPolicy IfNotPresent.

## Ports
| Service | Port | Target | Protocol |
| --- | --- | --- | --- |
| main | 4848 | 4848 | tcp |

## Volumes/paths
| Persistence | Mount | Note |
| --- | --- | --- |
| config | /config | enabled |
| downloads | /downloads | enabled |
| varrun | (none) | enabled: false |

## Env vars (chart)
| Var | Value | Source |
| --- | --- | --- |
| DATABASE_CONNECTION | secret `env-secrets` | secret key, default "" |
| http_PASS | secret `env-secrets` | secret key, default "" |
| http_USER | "" | literal |
| TUBESYNC_DEBUG | "False" | literal |
| TUBESYNC_HOSTS | "" | literal |
| TUBESYNC_WORKERS | "2" | literal |

## User/UID
- `runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`.

## Gotchas
- Chart runs as root with writable rootfs; upstream image uses PUID/PGID (see github file), chart does not set them.
- No probes defined in values.yaml.
