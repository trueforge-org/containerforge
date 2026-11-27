# TrueCharts chart: pwm

Source URL(s):
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/pwm/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/pwm/Chart.yaml
Fetched: 2026-11-27

## Chart.yaml
| Key | Value |
| --- | --- |
| version | 11.0.0 |
| appVersion | alpine |
| category | Security |
| kubeVersion | >=1.33.0-0 |
| dependency | common 32.8.5 (oci://oci.trueforge.org/truecharts) |
| sources | github.com/pwm-project/pwm; hub.docker.com/r/fjudith/pwm |

## values.yaml
| Key | Value |
| --- | --- |
| image.repository | docker.io/fjudith/pwm |
| image.tag | alpine@sha256:e56613b8867e80e8b525bfdf7404af344e1a4cf629b04e4e107428de9dfd569a |
| image.pullPolicy | IfNotPresent |
| securityContext.container.readOnlyRootFilesystem | false |
| securityContext.container.runAsUser | 0 |
| securityContext.container.runAsGroup | 0 |
| service.main.ports.main | port 8282, protocol tcp, targetPort 8080 |
| persistence.appdata | enabled, mountPath `/usr/share/pwm` |
| env PWM_APPLICATIONFLAGS | `NoFileLock` (workload.main.podSpec.containers.main.env) |

## Ports
- Service 8282 -> container 8080 (Tomcat, from Dockerfile EXPOSE 8080).

## Volumes/paths
- `/usr/share/pwm` (PWM_APPLICATIONPATH; configuration).

## User/UID
- Chart runs as root (runAsUser 0). Image Dockerfile creates user `pwm` (uid/gid 1234) and sets `USER pwm`.

## Env vars (chart)
| Name | Value |
| --- | --- |
| PWM_APPLICATIONFLAGS | NoFileLock |

## Gotchas
- Chart overrides the image USER with uid 0; the image itself is designed for uid 1234.
- Chart pins the `alpine` tag by digest; that tag was last pushed 2023-04-11.
