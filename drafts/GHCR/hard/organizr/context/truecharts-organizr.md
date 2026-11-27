# TrueCharts chart: organizr

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/organizr/{Chart.yaml,values.yaml} (fetched 2026-11-27)

## What it is
- Chart `organizr` v24.0.0, appVersion `latest`, category organizers.
- Depends on `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`. kubeVersion >=1.33.0-0; min helm 3.14; max helm 4.1; max k8s 1.35.0.

## Image
- repository: `ghcr.io/organizr/organizr`
- tag: `latest@sha256:52183b1eeb25632e68b677adafbcbaa5436d62cbbbe049edd4fcfa527baa0b1d`
- pullPolicy: Always

## Service / ports
- service.main.ports.main: port 10022 -> targetPort 80.

## Persistence
| Name | mountPath |
| --- | --- |
| config | /config |
| data | /data |

## Security
- readOnlyRootFilesystem false; runAsNonRoot false; runAsUser 0; runAsGroup 0.

## Gotchas
- Chart uses `latest` (not a versioned tag). Plan.md pins release 1.90; see README corrections.
- Chart adds a `/data` volume not present in the upstream Dockerfile VOLUME list.
