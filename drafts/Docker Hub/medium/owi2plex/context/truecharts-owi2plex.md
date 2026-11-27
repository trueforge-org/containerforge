# TrueCharts chart: owi2plex (stable)
Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/owi2plex/Chart.yaml , .../values.yaml (fetched 2026-11-27)

## What it is
- Chart version 11.0.0, appVersion `latest`, library dep `common` 32.8.5
- Description: "a xml grabber for enigma with open webif"; category Downloaders, train stable

## Image (values.yaml)
- repository: docker.io/alturismo/owi2plex
- tag: latest@sha256:559cdf995d558492f728523229d31d53ab92f2f108e0f9680ca21c88d293962f

## Ports
- service.main: enabled: false (no ports exposed)

## Persistence
| Name | mountPath |
| --- | --- |
| config | /config |
| owi2plex | /owi2plex |
| tvh | /TVH |

## Probes
- liveness, readiness, startup all enabled: false

## Security context
- readOnlyRootFilesystem: false, runAsUser: 0, runAsGroup: 0 (chart runs as root)
