# TrueCharts chart: pasta (stable)
Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/pasta/Chart.yaml , .../values.yaml (fetched 2026-11-27)

## What it is
- Chart version 16.0.0, appVersion 3.0.0, library dep `common` 32.8.5
- "PASTA - Audio and Subtitle Track Changer for Plex"; category MediaApp-Other; train stable
- kubeVersion >=1.33.0-0

## Image (values.yaml)
- repository: docker.io/cglatot/pasta
- tag: 3.0.0@sha256:8679a66df95f8a612e4ae6911078efa6c711340f268141de581e71b0a64fcea6

## Ports
| Service | Name | Protocol | Port | targetPort |
| --- | --- | --- | --- | --- |
| main | main | http | 10302 | 80 |

## Persistence
- none defined in values.yaml (no /config mount in chart; Docker image expects /config, see dockerhub-pasta.md)

## Security context
- readOnlyRootFilesystem: false, runAsNonRoot: false, runAsUser: 0, runAsGroup: 0

## Probes / env
- No probes, env or workload overrides set in values.yaml (chart defaults apply)
