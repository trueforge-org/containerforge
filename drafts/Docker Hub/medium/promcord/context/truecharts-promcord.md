# TrueCharts chart: promcord

Source URL(s):
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/promcord/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/promcord/Chart.yaml
Fetched: 2026-11-27

## What it is
Discord bot exposing Discord server metrics (Prometheus `/metrics`). Chart category: metrics. Chart version 17.0.0, train stable.

## Chart.yaml
| Key | Value |
| --- | --- |
| version | 17.0.0 |
| appVersion | latest |
| kubeVersion | >=1.33.0-0 |
| dependency | common 32.8.5 (oci://oci.trueforge.org/truecharts) |
| sources | github.com/nimarion/promcord; hub.docker.com/r/biospheere/promcord |

## values.yaml (image and config)
| Key | Value |
| --- | --- |
| image.repository | docker.io/biospheere/promcord |
| image.tag | latest@sha256:16d4fd269e665890d92e8ab2bf64f6cdd6f8bd45f27e829d414c4bad447c4974 |
| image.pullPolicy | IfNotPresent |
| service.main.ports.main | enabled, port 8080 |
| env | commented out (example `DISCORD_TOKEN`) |
| metrics.main | enabled, type servicemonitor, endpoint port `main`, path `/metrics`, prometheusRule disabled |
| securityContext.container.readOnlyRootFilesystem | false |

## Ports
- 8080 (service `main`, also metrics endpoint)

## Env vars
| Name | Note |
| --- | --- |
| DISCORD_TOKEN | required bot token (per README, via `.env`) |

## Gotchas
- Chart pins the Docker Hub `latest` tag by digest; the image is last pushed 2021-11-01 (see dockerhub-promcord.md).
- readOnlyRootFilesystem is explicitly false in chart values.
