# truecharts: vertex (chart 11.0.0, appVersion stable)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/vertex/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## Image
- repository `docker.io/lswl/vertex`, tag `stable@sha256:c62ce1ae12b0ee6f84d6480b6eed4ed81378f4d3f369e1b99da0f0b92c914cb8`, pullPolicy IfNotPresent.

## Security
- readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0 (root).

## Service / ports
| Service | Port | Protocol | targetPort |
| --- | --- | --- | --- |
| main | 3000 | tcp | 3000 |

## Persistence
| Name | enabled | mountPath |
| --- | --- | --- |
| config | true | `/vertex` |

## Env (chart-set)
| Env | Value |
| --- | --- |
| PORT | `"3000"` |

## Gotchas
- Chart data dir is `/vertex`, which matches the upstream Dockerfile `mkdir /vertex` and symlink targets.
- Chart runs as root.
