# TrueCharts chart: prpdf

Source URL(s):
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/prpdf/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/prpdf/Chart.yaml
Fetched: 2026-11-27

## Chart.yaml
| Key | Value |
| --- | --- |
| version | 11.0.0 |
| appVersion | latest |
| category | Productivity |
| kubeVersion | >=1.33.0-0 |
| dependency | common 32.8.5 (oci://oci.trueforge.org/truecharts) |
| description | Preview/rename scanned PDFs, rule-based autoscan with OCR, merge |
| sources | github.com/maschhoff/prpdf; hub.docker.com/r/knex666/prpdf |

## values.yaml
| Key | Value |
| --- | --- |
| image.repository | docker.io/knex666/prpdf |
| image.tag | latest@sha256:50964b7d20ea98e588b488119c840bdf2244c0cf02c185c99be4c0cf9dbdb968 |
| image.pullPolicy | IfNotPresent |
| securityContext.container.readOnlyRootFilesystem | false |
| securityContext.container.runAsUser | 0 |
| securityContext.container.runAsGroup | 0 |
| service.main | enabled false (no Service/port exposed by chart) |
| probes liveness/readiness/startup | all disabled |
| persistence.config | enabled, mountPath `/source/config` |
| persistence.files | enabled, mountPath `/Archiv/` |
| persistence.hostpath2 | enabled, mountPath `/source/static/pdf/` |

## Ports
- None set in chart (service disabled). Image default: FLASK_RUN_PORT=80 (see github-prpdf-dockerfile.md).

## Volumes/paths
- `/source/config` (config.json), `/Archiv/` (document archive), `/source/static/pdf/` (scan source folder).

## User/UID
- Runs as root (runAsUser 0, runAsGroup 0) per chart.

## Gotchas
- Chart exposes no service and disables probes; the app is only reachable if the port is wired by other means.
- Chart pins `latest` by digest; Docker Hub `latest` and `latest-dev` share that digest.
