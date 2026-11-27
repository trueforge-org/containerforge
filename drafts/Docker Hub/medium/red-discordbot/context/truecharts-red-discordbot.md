# TrueCharts chart: red-discordbot

Source URL(s):
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/red-discordbot/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/red-discordbot/Chart.yaml
Fetched: 2026-11-27

## Chart.yaml
| Key | Value |
| --- | --- |
| version | 11.0.1 |
| appVersion | full |
| category | Tools-Utilities |
| kubeVersion | >=1.33.0-0 |
| dependency | common 32.8.5 (oci://oci.trueforge.org/truecharts) |
| description | The newest Red-Discordbot in a convenient multi-arch Chart |
| sources | github.com/PhasecoreX/docker-red-discordbot; hub.docker.com/r/phasecorex/red-discordbot |

## values.yaml
| Key | Value |
| --- | --- |
| image.repository | docker.io/phasecorex/red-discordbot |
| image.tag | full@sha256:07a97b414b83acd993d0332a6e7dbdcf9c4cb25d2f316c2967b1946d6c0728b2 |
| image.pullPolicy | IfNotPresent |
| securityContext.container.readOnlyRootFilesystem | false |
| securityContext.container.runAsUser / runAsGroup | 0 / 0 |
| service.main | enabled false (no Service) |
| env PREFIX | "" (empty) |
| env TOKEN | secretKeyRef `env-secrets` / key `TOKEN` |
| secret env-secrets | enabled, data.TOKEN empty string |
| probes liveness/readiness/startup | all disabled |
| persistence.data | enabled, mountPath `/data` |

## Ports
- None exposed by chart. Image has no EXPOSE (RPC listens on localhost only, per README).

## Volumes/paths
- `/data` (VOLUME in Dockerfile): bot config.json, cogs, core, venv (`/data/venv`), pylav (`/data/pylav` for pylav variants).

## User/UID
- Chart forces root (runAsUser 0). Image default: non-root via PUID/PGID (default 1000) in user-entrypoint.

## Env vars (chart)
| Name | Source |
| --- | --- |
| PREFIX | literal "" |
| TOKEN | secret env-secrets.TOKEN |

## Gotchas
- Chart pins tag `full` by digest. The Dockerfile at the fetched commit defines no `full` stage (stages: core, extra, core-audio, extra-audio, core-pylav, extra-pylav); the `full` tag was not found on the first tags page (see dockerhub-red-discordbot.md).
- Chart has no Service and disables probes.
