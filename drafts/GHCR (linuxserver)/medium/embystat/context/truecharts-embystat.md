# TrueCharts chart: embystat
Source: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/embystat/values.yaml and .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart embystat 15.0.0, appVersion 0.2.0
- Home https://truecharts.org/charts/stable/embystat
- Sources: https://ghcr.io/linuxserver/embystat, truecharts chart tree

## Dependencies
- common 32.8.5 from oci://oci.trueforge.org/truecharts

## Image
- ghcr.io/linuxserver/embystat, tag 0.2.0 (sha256 pinned), pullPolicy IfNotPresent

## Ports
- Service main 6555 -> container targetPort 6555

## Env vars
- None (env map empty)

## Volumes/paths
- config: enabled, mountPath /config

## Probes
- liveness, readiness, startup: HTTP GET path "/"

## User/UID
- securityContext.container: runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false
