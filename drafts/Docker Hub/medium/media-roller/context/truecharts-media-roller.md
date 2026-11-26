# TrueCharts chart: media-roller

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/media-roller/values.yaml, .../Chart.yaml (fetched 2026-11-26)

## What it is
- Chart `media-roller`, version 11.0.1, appVersion "latest"
- Description: mobile friendly tool for downloading videos from social media
- Depends on `common` 32.8.5 from oci://oci.trueforge.org/truecharts

## Image
- Repository: docker.io/ronnieroller/media-roller
- Tag: latest@sha256:a2837c7505fcf9b117f4cfcab094cb88ac2ce6b550468d079045e99bfaa10fa2
- pullPolicy: IfNotPresent

## Ports
- Service main: port 3000 tcp -> targetPort 3000

## Env vars
- None set in values.yaml

## Volumes/paths
| Name | Enabled | mountPath |
| --- | --- | --- |
| download | true | /download |

## Probes
- None set in values.yaml

## Security
- readOnlyRootFilesystem: false
- runAsUser: 0, runAsGroup: 0
- fsGroup: not set

## Gotchas
- Chart runs as root with a writable rootfs; no probes defined.
