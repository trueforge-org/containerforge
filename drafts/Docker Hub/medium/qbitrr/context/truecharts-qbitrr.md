# TrueCharts chart: qbitrr

Source URL(s):
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/qbitrr/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/qbitrr/Chart.yaml
Fetched: 2026-11-27

## Chart.yaml
| Key | Value |
| --- | --- |
| version | 11.0.0 |
| appVersion | 5.12.12 |
| category | Downloaders |
| kubeVersion | >=1.33.0-0 |
| dependency | common 32.8.5 (oci://oci.trueforge.org/truecharts) |
| sources | github.com/Feramance/Qbitrr; hub.docker.com/r/feramance/qbitrr |

## values.yaml
| Key | Value |
| --- | --- |
| image.repository | docker.io/feramance/qbitrr |
| image.tag | v5.12.12@sha256:60843fc5b43511e6e50a09b1dd79faeae5706cd146320729ad770ce2966ec3f9 |
| image.pullPolicy | IfNotPresent |
| securityContext.container.readOnlyRootFilesystem | false |
| securityContext.container.runAsUser / runAsGroup | 0 / 0 |
| securityContext.container.runAsNonRoot | false |
| service.main | enabled false (no Service exposed by chart) |
| probes liveness/readiness/startup | all disabled |
| env QBITRR_OVERRIDES_DATA_PATH | /config |
| persistence.config | enabled, mountPath `/config`; shared with init container |
| persistence.downloads | enabled, mountPath `/completed_downloads` |

## initContainer `1-create-config-file` (type install)
- Image: same as main (imageSelector "image").
- Shell: if `/config/config.toml` exists, skip; else `wget` https://raw.githubusercontent.com/Feramance/qBitrr/master/config.example.toml to `/config/config.toml` (failure only echoed).
- Note: downloads from unpinned `master` branch at install time.

## Ports
- None exposed by chart. Upstream image: EXPOSE 6969 (WebUI at /ui).

## Volumes/paths
- `/config` (config.toml, overrides data), `/completed_downloads` (download dir).

## User/UID
- Chart runs as root. Image creates user/group `qbitrr` (system user, home /config) and drops privileges via gosu in entrypoint (docker-entrypoint.sh, not fetched).

## Gotchas
- Chart has no Service: WebUI on 6969 is not reachable through the chart as shipped.
- Chart pins v5.12.12 (appVersion 5.12.12); latest upstream release is v5.14.9-4 (see github-qbitrr-release-dockerfile.md).
