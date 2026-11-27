# TrueCharts chart: quiz-game

Source URL(s):
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/quiz-game/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/quiz-game/Chart.yaml
Fetched: 2026-11-27

## Chart.yaml
| Key | Value |
| --- | --- |
| version | 11.0.0 |
| appVersion | latest |
| category | GameServers |
| kubeVersion | >=1.33.0-0 |
| dependency | common 32.8.5 (oci://oci.trueforge.org/truecharts) |
| description | Test your General Knowledge in different types of topics. |
| sources | github.com/ASKJR/quiz-game; hub.docker.com/r/patrickstigler/quiz-game |

## values.yaml
| Key | Value |
| --- | --- |
| image.repository | docker.io/patrickstigler/quiz-game |
| image.tag | latest@sha256:553f335b16bdbd87b4b640d6a266b0d3fbf982f18ec6365b8dfc2bd18fc3e0e1 |
| image.pullPolicy | IfNotPresent |
| securityContext.container.readOnlyRootFilesystem | false |
| securityContext.container.runAsUser / runAsGroup | 0 / 0 |
| service.main.ports.main | port 10588, protocol http, targetPort 80 |
| persistence.config | enabled, mountPath `/app` |

## Ports
- Service 10588 -> container 80 (nginx).

## Volumes/paths
- `/app` (chart mount; image serves static files from /usr/share/nginx/html).

## Gotchas
- Mount of `/app` does not match the image layout (static files are in /usr/share/nginx/html per Dockerfile); verify before relying on it.
- Chart pins `latest` digest 553f335b...; the only tag, last pushed 2022-01-31.
