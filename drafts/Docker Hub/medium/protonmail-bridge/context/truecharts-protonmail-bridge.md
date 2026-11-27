# TrueCharts chart: protonmail-bridge

Source URL(s):
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/protonmail-bridge/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/protonmail-bridge/Chart.yaml
Fetched: 2026-11-27

## Chart.yaml
| Key | Value |
| --- | --- |
| version | 20.0.0 |
| appVersion | 3.19.0 |
| category | media |
| kubeVersion | >=1.33.0-0 |
| dependency | common 32.8.5 (oci://oci.trueforge.org/truecharts) |
| sources | github.com/shenxn/protonmail-bridge-docker; hub.docker.com/r/shenxn/protonmail-bridge |

## values.yaml
| Key | Value |
| --- | --- |
| image.repository | docker.io/shenxn/protonmail-bridge |
| image.tag | 3.19.0-1@sha256:3717b4441130675dc9131196de9f9c5287d2ea21b138d83b0486429e1737638a |
| image.pullPolicy | IfNotPresent |
| securityContext.container.readOnlyRootFilesystem | false |
| securityContext.container.runAsNonRoot | false |
| securityContext.container.runAsUser | 0 |
| securityContext.container.runAsGroup | 0 |
| service.main | enabled false |
| service.smtp | enabled, primary, port 25/tcp, targetPort 25 |
| service.imap | enabled, port 143/tcp, targetPort 143 |
| probes (liveness, readiness, startup) | tcp on `service.smtp.ports.smtp.targetPort` (25) |
| persistence.config | enabled, mountPath `/root` |

## Ports
- 25/tcp (SMTP, primary), 143/tcp (IMAP)

## Volumes/paths
- `/root` (bridge state, config, vault; persisted via `persistence.config`)

## User/UID
- Chart forces root (runAsUser 0, runAsGroup 0, runAsNonRoot false). Not rootless.

## Gotchas
- Chart pins tag `3.19.0-1` (the `deb` variant; amd64 only). Upstream latest GitHub release is v3.27.2 (see github-proton-bridge-release.md).
- Init (account login) is interactive: `docker run --rm -it -v <vol>:/root shenxn/protonmail-bridge init`, then `login`, `info`, `exit`.
