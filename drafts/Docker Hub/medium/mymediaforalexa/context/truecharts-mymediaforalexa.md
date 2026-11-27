# truecharts mymediaforalexa (stable)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/mymediaforalexa/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## Chart
- name mymediaforalexa, chart version 14.0.0, appVersion 1.3.156.0
- dependency: common 32.8.5 (oci://oci.trueforge.org/truecharts)
- kubeVersion >=1.33.0-0; max helm 4.1, min 3.14; max k8s 1.35.0
- category: media; keywords media, alexa
- sources: hub bizmodeller/mymediaforalexa, mymediaalexa.com/home/docker

## Image (values.yaml)
- repository: docker.io/bizmodeller/mymediaforalexa
- tag: 1.3.156.0@sha256:0638ca161d15de60cab8b0f75b440e435c6ccc134f384990e006a7198aa33ca8
- pullPolicy: IfNotPresent

## Security context (chart default)
- runAsNonRoot: false, runAsUser: 0, runAsGroup: 0, readOnlyRootFilesystem: false

## Ports
| service | port | targetPort |
| --- | --- | --- |
| main | 52051 | 52051 |
| sub (enabled) | 52050 | 52050 |

## Persistence
| name | mountPath |
| --- | --- |
| data | /datadir |
| media | /medialibrary |

## Env / probes
- none set in values.yaml
