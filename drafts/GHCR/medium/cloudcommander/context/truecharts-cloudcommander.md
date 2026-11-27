# TrueCharts cloudcommander (stable)
Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/cloudcommander/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## What it is
- CloudCommander web file browser (chart description). Chart version 12.0.2, appVersion 19.24.6.
- Chart `common` dependency 32.8.5 (oci://oci.trueforge.org/truecharts). Kube >=1.33.0-0, max k8s 1.35.0, helm 3.14 to 4.1.

## Image (values.yaml)
- repository: ghcr.io/coderaiser/cloudcmd
- tag: 19.24.6@sha256:19cf55845d7f2910e29b5161cea00c084221d4332ce2d135ca7eea419d1451d8
- pullPolicy: IfNotPresent

## Ports
| Name | Service port | targetPort | Proto |
| --- | --- | --- | --- |
| main | 8765 | 8000 | tcp |

## Persistence
| Name | mountPath | Notes |
| --- | --- | --- |
| appdata | /root | enabled |
| mountpath | /UNRAID | enabled (host mount) |

## Security / user
- securityContext.container: runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false (runs as root).

## Env
| Name | Value |
| --- | --- |
| HOME | /root |

## Gotchas
- Chart runs as root with writable rootfs; not rootless. No probes defined in values.yaml.
