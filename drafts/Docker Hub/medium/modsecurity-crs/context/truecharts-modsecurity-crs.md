# truecharts modsecurity-crs (stable)

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/modsecurity-crs/values.yaml, .../Chart.yaml (fetched 2026-11-27)

## Chart
- name: modsecurity-crs, chart version 9.0.0, appVersion 3.3.4
- dependency: common 32.8.5 (oci://oci.trueforge.org/truecharts)
- kubeVersion >=1.33.0-0; trueforge.org/max_helm_version 4.1, min 3.14; max k8s 1.35.0
- sources: github.com/coreruleset/modsecurity-crs-docker, truecharts chart path
- description: ModSecurity open source WAF engine

## Image (values.yaml)
- repository: docker.io/owasp/modsecurity-crs
- tag: 3.3.4-apache-202307110507 (pinned with sha256 digest 0ee904f1...)
- pullPolicy: IfNotPresent

## Security context (chart default)
- runAsNonRoot: false, runAsUser: 0, runAsGroup: 0
- readOnlyRootFilesystem: false

## Ports
| name | protocol | port |
| --- | --- | --- |
| main | http | 8081 |

## Env (chart-injected)
| var | value |
| --- | --- |
| PORT | service.main.ports.main.port (8081) |
| MODSEC_DATA_DIR | /modsecurity/data |
| MODSEC_TMP_DIR | /modsecurity/temp |
| MODSEC_UPLOAD_DIR | /modsecurity/upload |

## Probes (chart)
- liveness, readiness, startup: HTTP path /healthz

## Persistence (chart defaults, all emptyDir)
| name | mountPath |
| --- | --- |
| data | /modsecurity/data |
| temp | /modsecurity/temp |
| upload | /modsecurity/upload |
