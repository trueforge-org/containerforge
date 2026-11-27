# TrueCharts chart: thunderbird

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/thunderbird/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- TrueCharts Helm chart wrapping `ghcr.io/ich777/thunderbird` (Thunderbird in noVNC, browser UI).
- Chart `version: 11.0.0`, `appVersion: latest`, category productivity, train stable.

## Runtime deps
- Helm library: `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`.
- kubeVersion `>=1.33.0-0`; max helm 4.1; min helm 3.14.

## Ports
| Name | Service port | Target | Note |
| --- | --- | --- | --- |
| main | 10291 | 8080 | noVNC web UI |

## Volumes/paths
| Persistence | Mount | Note |
| --- | --- | --- |
| data | /thunderbird | enabled: true |

## Env vars (chart defaults)
| Var | Value |
| --- | --- |
| CUSTOM_RES_H | "768" |
| CUSTOM_RES_W | "1280" |
| DATA_PERM | "770" |
| THUNDERBIRD_LANG | en-US |
| THUNDERBIRD_V | latest |

## User/UID
- securityContext.container: `runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`.

## Image
- `image.repository: ghcr.io/ich777/thunderbird`, `tag: latest@sha256:246f5631...` (pinned digest, pullPolicy IfNotPresent).

## Gotchas
- Chart runs as root with a writable rootfs; the plan's rootless/read-only goals are not reflected in the upstream chart.
- No probes or healthcheck defined in values.yaml.
