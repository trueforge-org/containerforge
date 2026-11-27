# TrueCharts chromium (stable)
Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/chromium/values.yaml ; .../Chart.yaml (fetched 2026-11-27)

## What it is
Chromium browser chart, TrueCharts "stable" train, category Productivity. Chart version 12.0.1, appVersion `latest`.

## Image
- repository: `ghcr.io/linuxserver/chromium`
- tag: `latest@sha256:03e51eb010a4c3ff93ae0440c5b5d22ff5ae0a3c2898e292cf4d0bcd1ef9088e`
- pullPolicy: IfNotPresent

## Persistence
| name | enabled | type | mountPath |
| --- | --- | --- | --- |
| datadir | true | (default PVC) | /config |
| browsercache | true | emptyDir | /config/.cache |

## Service / ports
- service.main.ports.main: port 8080/tcp, targetPort 8080
- env `CUSTOM_PORT` = service port (8080)

## Security context
- container: readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0
- No probes, podSecurityContext, fsGroup or resources keys in values.yaml

## Chart deps / metadata
- dependency: `common` 32.8.5 from oci://oci.trueforge.org/truecharts
- sources listed: ghcr.io/linuxserver/chromium, github linuxserver/docker-chromium, google chrome
- kubeVersion >=1.33.0-0

## Gotchas
- Chart runs as root (UID/GID 0) with rootfs writable; not rootless.
