# TrueCharts chart: dillinger
Source: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/dillinger/values.yaml and .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart dillinger 15.0.0, appVersion 3.39.1
- Home https://truecharts.org/charts/stable/dillinger
- Sources: https://ghcr.io/linuxserver/dillinger, truecharts chart tree

## Dependencies
- common 32.8.5 from oci://oci.trueforge.org/truecharts (no condition/alias/tags)

## Image
- ghcr.io/linuxserver/dillinger, tag 3.39.1 (sha256 pinned), pullPolicy IfNotPresent

## Ports
- Service main 10143 -> container targetPort 8080

## Env vars
- None (env map empty)

## Volumes/paths
- config: enabled, mountPath /config

## Probes
- liveness, readiness, startup: HTTP GET path "/"

## User/UID
- securityContext.container: runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false
