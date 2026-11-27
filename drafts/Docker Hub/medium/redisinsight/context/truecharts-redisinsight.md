# TrueCharts chart: redisinsight

Source URL(s):
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/redisinsight/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/redisinsight/Chart.yaml
Fetched: 2026-11-27

## Chart.yaml
| Key | Value |
| --- | --- |
| version | 14.0.1 |
| appVersion | 3.10.2 |
| category | Tools-Utilities |
| kubeVersion | >=1.33.0-0 |
| dependency | common 32.8.5 (oci://oci.trueforge.org/truecharts) |
| sources | github.com/RedisInsight/RedisInsight; hub.docker.com/r/redislabs/redisinsight |

## values.yaml
| Key | Value |
| --- | --- |
| image.repository | docker.io/redislabs/redisinsight |
| image.tag | 3.10.2@sha256:2c4684628233e6f3aee1d8279b54cd19f420afb64b8ce6d9cc477919c234373d |
| image.pullPolicy | IfNotPresent |
| securityContext.container.readOnlyRootFilesystem | false |
| securityContext.container.runAsNonRoot | false |
| securityContext.container.runAsUser / runAsGroup | 0 / 0 |
| service.main.ports.main | protocol http, port 10579 |
| redisinsight.log_level | info |
| env RI_APP_PORT | `{{ service.main.ports.main.port }}` (10579) |
| env RI_FILES_LOGGER | /logs |
| env RI_LOG_LEVEL | `{{ redisinsight.log_level }}` |
| persistence.config | enabled, mountPath `/data` |
| persistence.logs | enabled, mountPath `/logs` |

## Ports
- Service 10579 (env RI_APP_PORT). Image Dockerfile: EXPOSE 5540 (comment says app is hard-coded to 5540). Whether RI_APP_PORT overrides the 5540 default is not verified from the fetched sources.

## Volumes/paths
- `/data` (RI_APP_FOLDER_ABSOLUTE_PATH: local DB, plugins, logs), `/logs` (RI_FILES_LOGGER).

## User/UID
- Image sets `USER node` (uid 1000). Chart forces runAsUser 0 and runAsNonRoot false.

## Gotchas
- Chart overrides the image's non-root user.
- Chart pins 3.10.2 (multi-arch index digest 2c468462...); the same digest is `latest` and `3.10` on Docker Hub.
