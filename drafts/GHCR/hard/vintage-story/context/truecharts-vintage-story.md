# TrueCharts chart: vintage-story

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/vintage-story/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- TrueCharts chart for `ghcr.io/ich777/vintagestory` (basic Vintage Story server, downloads server at start).
- Chart `version: 11.0.0`, `appVersion: latest`, category GameServers, train stable.

## Runtime deps
- Helm library `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`.
- kubeVersion `>=1.33.0-0`; max helm 4.1; min helm 3.14.

## Image
- `repository: ghcr.io/ich777/vintagestory`, `tag: latest@sha256:c2a3381d...`, pullPolicy IfNotPresent.

## Ports
| Service | Port | Target | Protocol |
| --- | --- | --- | --- |
| main | 42420 | 42420 | tcp |

## Env vars (chart)
| Var | Value |
| --- | --- |
| GAME_PARAMS | "" |
| VS_CHANNEL | stable@sha256:f0065aa4... (value is a digest string, not a channel name; flag) |

## Volumes/paths
| Persistence | Mount | Note |
| --- | --- | --- |
| serverfiles | /vintagestory | enabled |

## User/UID
- `runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`.

## Gotchas
- `VS_CHANNEL` value includes `@sha256:` digest suffix; upstream expects channel name `stable` (see upstream ENV default `stable`).
- Chart runs as root with writable rootfs.
- No probes in values.yaml.
