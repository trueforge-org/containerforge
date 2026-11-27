# TrueCharts chart: seedsync

Source URL(s): https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/seedsync/values.yaml , .../Chart.yaml (fetched 2026-11-27)

## What it is
- TrueCharts `seedsync`. Chart version 13.0.0, appVersion `latest`.
- Description: sync files from a remote Linux server (seedbox) using LFTP.
- Library dependency: `common` 32.8.5 from `oci://oci.trueforge.org/truecharts`. No other dependencies.
- kubeVersion `>=1.33.0-0`.
- Chart `sources:` list: github ipsingh06/seedsync, truecharts chart path, hub.docker.com/r/ipsingh06/seedsync.

## Image (values.yaml)
- repository `docker.io/ipsingh06/seedsync`, tag `latest@sha256:78715911d1c3510c3dcc595a109778e541faa4f6ebb836b0e396e840509a2c33`, pullPolicy IfNotPresent.

## Ports
- service.main.ports.main: port 8800, protocol http, targetPort 8800.

## Persistence
- persistence.config: enabled, mountPath `/config`.
- persistence.downloads: enabled, mountPath `/downloads`.

## Security
- securityContext.container: readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0 (chart runs as root; upstream image runs as seedsync uid 1000).

## Env / probes / secrets
- No env, probes or secrets set in values.yaml.

## Gotchas
- Chart runs as root, upstream image sets `USER seedsync` (1000). Chart pins image by digest with tag `latest`; Docker Hub `latest` last pushed 2020-12-31.
