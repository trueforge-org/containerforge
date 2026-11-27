# TrueCharts chart: openhab (stable)
Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/openhab/Chart.yaml , .../values.yaml (fetched 2026-11-27)

## What it is
- Chart version 16.0.0, appVersion 5.2.5, library dep `common` 32.8.5 (oci://oci.trueforge.org/truecharts)
- Category media, train stable, description "OpenHab is a home-automation application"
- kubeVersion >=1.33.0-0; max helm 4.1, min helm 3.14

## Image (values.yaml)
- repository: docker.io/openhab/openhab
- tag: 5.2.5@sha256:78bb11484098841c7a58fe101507b423d007ca0d17623dd2eea8fa26816a0f81

## Ports
| Service | Name | Protocol | Port |
| --- | --- | --- | --- |
| main | main | http | 10169 |
| https (enabled) | https | https | 10170 |

## Env (workload main, container main)
| Env | Value |
| --- | --- |
| OPENHAB_HTTP_PORT | {{ .Values.service.main.ports.main.port }} (10169) |
| OPENHAB_HTTPS_PORT | {{ .Values.service.https.ports.https.port }} (10170) |

## Persistence (mountPath)
| Name | Path |
| --- | --- |
| config | /openhab/conf |
| addons | /openhab/addons |
| userdata | /openhab/userdata |
| init | /etc/cont-init.d/enable-console-logging.sh (configmap, subPath enable-console-logging.sh) |

- configmap init script: sed on /openhab/userdata/etc/log4j2.xml to add `<AppenderRef ref="STDOUT"/>` (console logging)

## Security context
- readOnlyRootFilesystem: false, runAsNonRoot: false, runAsUser: 0, runAsGroup: 0 (chart runs as root)

## Probes
- liveness, readiness, startup all type tcp (no port given; default container port)
