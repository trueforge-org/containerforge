# TrueCharts chart: plex-utills

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/plex-utills (directory listing)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/plex-utills/values.yaml
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/plex-utills/Chart.yaml
- Fetched 2026-11-26

## What it is
- TrueCharts Helm chart `plex-utills`, stable train. Chart version 14.0.0, appVersion `latest`.
- Install: `helm install mychart oci://oci.trueforge.org/truecharts/plex-utills`.
- README says the chart is not maintained by the upstream project.
- Category: Tools-Utilities. Min Helm 3.14, max Helm 4.1, max Kubernetes 1.35.0.

## Image (chart values)
- Repository `docker.io/jkirkcaldy/plex-utills`, tag `latest@sha256:33ca56a98ee662d1a23d6e313bd15317648f028a1458c72a2e5c1fa294e50159`, pull policy IfNotPresent.

## Ports
- Service main port 10380 (protocol http), target port 80.

## Volumes/paths
- `config` -> `/config`, `logs` -> `/logs`, `plexlibrary` -> `/films`. All enabled.

## User/UID & permissions
- securityContext: runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false.

## Env vars
- None set in values.yaml.

## Gotchas
- Chart assumes port 80 for the app (consistent with the wiki `-p 80:80`), unlike the Dockerfile's `EXPOSE 5000`-only plan.
- Chart runs as root with a writable rootfs; plan.md changes this.
