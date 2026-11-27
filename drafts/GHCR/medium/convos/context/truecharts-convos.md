# TrueCharts convos (stable)
Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/convos/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- Convos: IRC client that is always online (chart description). Chart version 12.0.0, appVersion 8.07.0. Category Network-Messenger.
- Dependency common 32.8.5 (oci://oci.trueforge.org/truecharts). Kube >=1.33.0-0.

## Image
- repository: ghcr.io/convos-chat/convos
- tag: v8.07@sha256:d9ab6aefce1b47a1e6d10c70a558ae0120a35e32b1f92d87ca364bfa17f1f3a6
- pullPolicy: IfNotPresent

## Ports
| Name | port | targetPort | proto |
| --- | --- | --- | --- |
| main | 3520 | 3000 | tcp |

## Persistence
| Name | mountPath |
| --- | --- |
| data | /data |

## Security
- securityContext.container: runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false.

## Gotchas
- Chart runs as root; no env overrides, no probes in values.yaml.
