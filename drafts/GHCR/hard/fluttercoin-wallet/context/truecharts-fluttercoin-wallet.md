# TrueCharts: fluttercoin-wallet (stable)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/fluttercoin-wallet/Chart.yaml , .../values.yaml (fetched 2026-11-27)

## What it is
- Chart name fluttercoin-wallet, chart version 11.0.0, appVersion `latest`.
- Description: "FlutterCoin ... scrypt ..."; sources: https://fluttercoin.me/, https://ghcr.io/ich777/fluttercoin.
- Dependency: `common` 32.8.5 from oci://oci.trueforge.org/truecharts.
- kubeVersion >=1.33.0-0; trueforge.org/min_helm_version 3.14.

## Image (values.yaml)
- repository: ghcr.io/ich777/fluttercoin
- tag: latest@sha256:a74769e2806669ea722a49ac9b69852872e62fee0570ff23ed2bd5511c5ad421
- pullPolicy: IfNotPresent

## Env (workload.main.podSpec.containers.main.env)
| Name | Value |
| --- | --- |
| CUSTOM_RES_H | "768" |
| CUSTOM_RES_W | "1024" |
| DATA_PERM | "770" |
| EXTRA_PARAMS | -bind=0.0.0.0 |

## Ports (service)
| Name | Port | Protocol | Target |
| --- | --- | --- | --- |
| main | 8080 | http | 8080 |
| jsonremoteport | 7474 | tcp | 7474 |
| peertopeerconn | 7408 | tcp | 7408 |

## Persistence
- datapath: mountPath `/fluttercoin`, enabled.

## Security
- readOnlyRootFilesystem: false; runAsUser 0; runAsGroup 0.

## Gotchas
- Chart runs as root (uid 0), not a non-root user; readOnlyRootFilesystem disabled.
- Chart pins the upstream ich777 image by digest, not a version tag.
