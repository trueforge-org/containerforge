# TrueCharts chart: fivem

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/fivem/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart `fivem` v12.0.0, `appVersion: latest`, category GameServers, train stable.
- Depends on `common` 32.8.5 (oci://oci.trueforge.org/truecharts).
- Chart description: auto-downloads latest FiveM artifact unless `MANUAL_UPDATES` is true; needs a valid SERVER_KEY.

## Image
- repository: `ghcr.io/ich777/fivemserver` (GHCR, not Docker Hub)
- tag: `latest@sha256:6534fde2a257c976738049fda0d11f2b257c92806c19d1acde6d4fb095c7dd3f`

## Ports
| Service | Port | Target | Proto |
| --- | --- | --- | --- |
| main | 9016 | 8080 | http |
| port1tcp / port1udp | 30110 | 30110 | tcp / udp |
| port2tcp / port2udp | 30120 | 30120 | tcp / udp |

## Env vars (values.yaml, workload main)
| Name | Chart value | Note |
| --- | --- | --- |
| GAME_CONFIG | server.cfg | |
| MANUAL_UPDATES | "" | set `true` to manage artifact yourself |
| SERVER_KEY | secretKeyRef `env-secrets`/`SERVER_KEY` | chart default empty |
| SRV_ADR | https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/ | artifact index |
| SRV_NAME | "" | |
| START_VARS | "" | |

## Volumes/paths
- persistence `serverfiles`: mountPath `/serverdata/serverfiles`

## User/UID
- chart securityContext: runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false

## Gotchas
- Chart default env differs from image: image `SERVER_KEY` default is `template`, chart empty.
