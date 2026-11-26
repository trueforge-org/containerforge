# TrueCharts chart: guacamole
Source URL(s): https://github.com/trueforge-org/truecharts/tree/master/charts/stable/guacamole (raw values.yaml + Chart.yaml fetched 2026-11-26; values.yaml 261 lines)

## Chart.yaml
- version 19.0.0, appVersion 1.6.0
- dependencies: common 32.8.5; postgresql (enabled, depconfig user/db guacamole)

## Images
| Key | Value |
| --- | --- |
| image | docker.io/guacamole/guacamole:1.6.0@sha256:f344085e618bb05e22b964b0208dbd06d3468275bac70206f93805245e067b40 |
| guacdImage | docker.io/guacamole/guacd:1.6.0@sha256:8974eaa9ba32f713daf311e7cc8cd7e4cdfba1edea39eed75524e78ef4b08f4f |

## Ports
| Service | Port | TargetPort |
| --- | --- | --- |
| main | 10123 | 8080 (http) |
| guacd | 10124 | guacd (guacd listens on -l 10124 in chart args) |

## Main container
- runAsUser 1001 / runAsGroup 1001; readOnlyRootFilesystem false
- envFrom secretRef guacamole-config (Guacamole env vars are supplied via this secret, not in values)
- Probes: liveness/readiness HTTP on targetPort 8080; startup TCP 8080
- initContainers: 1-create-seed (/bin/sh -c /tc-scripts/create-seed.sh), 2-apply-seed (/tc-scripts/apply-seed.sh; postgres client image), both runAsUser 1001
- Config defaults under guacamole.*: EXTENSION_PRIORITY "", API_SESSION_TIMEOUT 60; all auth extensions (ldap, header, saml, proxy, totp, duo, radius, openid, cas, json) empty and commented.

## guacd container (Deployment)
- command: /opt/guacamole/sbin/guacd -b 0.0.0.0 -l 10124 -L info -f
- runAsUser 1000, runAsGroup 1001
- Probes: TCP on port 10124 (liveness/readiness/startup)

## Volumes / paths
| Mount | Type | Path / target |
| --- | --- | --- |
| recordings | persistence | main: /var/lib/guacamole/recordings (readOnly true); guacd: /var/lib/guacamole/recordings |
| drive | persistence | guacd: /var/lib/guacamole/drive |
| tc-init | emptyDir | /tc-init (create-seed and apply-seed) |
| db-seed | configmap db-init, defaultMode 0770 | /tc-scripts/create-seed.sh, /tc-scripts/apply-seed.sh |

## Other
- dependency postgresql enabled
- No healthcheck overrides beyond probes above
- Guacd and main are separate workloads/pods (guacd service targetSelector guacd)

## Gotchas
- Chart sets guacd -l to 10124 while the Docker docs say guacd default is 4822. The chart overrides it.
