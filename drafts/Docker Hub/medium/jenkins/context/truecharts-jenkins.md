# TrueCharts chart: jenkins
Source URL(s): https://github.com/trueforge-org/truecharts/tree/master/charts/stable/jenkins (raw values.yaml + Chart.yaml fetched 2026-11-26; values.yaml 52 lines)

## Chart.yaml
- version 13.0.0, appVersion 2.544.0; common 32.8.5; min helm 3.14, max helm 4.1

## values.yaml
| Key | Value |
| --- | --- |
| image.repository | docker.io/jenkins/jenkins |
| image.tag | 2.544-jdk17@sha256:c9059deaa1a6b393ea6a447b13efca888d1817a57b924df9424a7075f51d9348 |
| security.container | runAsUser 1000, runAsGroup 1000 |
| security.pod.fsGroup | 1000 |
| jenkins.java_opts / jenkins_opts / jenkins_java_opts | [] (empty lists) |
| jenkins.plugins_force_upgrade | false |
| jenkins.upgrade_if_no_marker | false |
| service.main.ports.main | protocol http, port 10280 |
| service.agent.ports.agent | enabled, port 50000 |
| persistence.data | mountPath /var/jenkins_home |

## Probes / env
- liveness and readiness: HTTP GET /login
- startup: TCP
- envFrom secretRef: jenkins-secret

## Notes
- Chart service port 10280 is the external port; container listens on upstream default 8080 (Dockerfile ARG http_port=8080).
- Chart does not set readOnlyRootFilesystem (not in values).
