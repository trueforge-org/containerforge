# TrueCharts couchpotato (stable)
Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/couchpotato/values.yaml ; .../Chart.yaml (fetched 2026-11-27)

## What it is
Automatic NZB/torrent downloader (CouchPotato). Chart version 15.0.0, appVersion `latest`, category incubator, train stable.

## Image
- repository: `ghcr.io/linuxserver/couchpotato`
- tag: `latest@sha256:f846573965e3daf1bb8c9c49bb18ddcbc90ba98bd036eb8a42ebf4c46957cf4a`
- pullPolicy: IfNotPresent

## Service / ports
- service.main.ports.main: port 10139, protocol http, targetPort 5050

## Probes
- liveness, readiness, startup: http GET `/`

## Persistence
| name | enabled | mountPath |
| --- | --- | --- |
| config | true | /config |

## Security context
- container: runAsNonRoot false, runAsUser 0, runAsGroup 0
- env: {}

## Chart deps
- `common` 32.8.5 from oci://oci.trueforge.org/truecharts; kubeVersion >=1.33.0-0

## Gotchas
- Chart runs as root; targetPort 5050 matches upstream EXPOSE.
