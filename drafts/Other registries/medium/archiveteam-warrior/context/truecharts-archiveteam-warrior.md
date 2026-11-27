# TrueCharts chart: archiveteam-warrior

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/archiveteam-warrior/Chart.yaml (fetched 2026-11-27)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/archiveteam-warrior/values.yaml (fetched 2026-11-27)

## What it is
- Chart `archiveteam-warrior` version 11.0.0, appVersion `latest`, category Backup.
- Depends on `common` 32.8.5 (`oci://oci.trueforge.org/truecharts`). kubeVersion `>=1.33.0-0`; min helm 3.14, max helm 4.1.

## Image
- `atdr.meo.ws/archiveteam/warrior-dockerfile` tag `latest@sha256:66d89a09583c870944b477d2a71309a782fddaae6dfbe61d1afcbdbf9a135804`, pullPolicy IfNotPresent.

## Ports
- `service.main.ports.main`: port 8001, protocol tcp, targetPort 8001.

## Security context
- `runAsUser: 0`, `runAsGroup: 0`, `readOnlyRootFilesystem: false`.

## Persistence / env / probes
- None defined in values.yaml (no persistence, no env, no probes).

## Gotchas
- Chart runs as root; upstream Dockerfile sets `USER 1000` (warrior). Chart override runs as 0.
- Chart port protocol is `tcp`, not `http`.
- No persistence in chart; upstream data dir is `/home/warrior/data` (not mounted by chart).
