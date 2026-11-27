# truecharts: unmanic (chart 16.0.0, appVersion 0.4.1)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/unmanic/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## Image
- repository `docker.io/josh5/unmanic`, tag `0.4.1@sha256:b249cba0d77331fe015794dc06f98cc4c99c50f158cfce43575a1b4f330495a9`, pullPolicy IfNotPresent.

## Service / ports
| Service | Port | targetPort |
| --- | --- | --- |
| main | 10157 | 8888 |

## Persistence
| Name | enabled | mountPath | type |
| --- | --- | --- | --- |
| config | true | `/config` | PVC |
| library | true | `/library` | PVC |
| remote | true | `/tmp/unmanic/remote_library` | PVC |
| cache | true | `/tmp/unmanic` | emptyDir |

## Gotchas
- Chart service port 10157 maps to container 8888 (Unmanic's listen port per Dockerfile).
- Library mounted at `/library` (Dockerfile creates `/library`).
- Cache is an emptyDir at `/tmp/unmanic`.
