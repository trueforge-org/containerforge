# TrueCharts chart: booksonic-air
Source: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/booksonic-air/values.yaml and .../Chart.yaml (fetched 2026-11-27)

## What it is
- Chart booksonic-air 19.0.0, appVersion 2201.1.0
- Home https://truecharts.org/charts/stable/booksonic-air
- Sources: https://ghcr.io/linuxserver/booksonic-air, https://github.com/popeen/Booksonic-Air

## Dependencies
- common 32.8.5 from oci://oci.trueforge.org/truecharts

## Image
- ghcr.io/linuxserver/booksonic-air, tag 2201.1.0 (sha256 digest pinned), pullPolicy IfNotPresent

## Ports
- Service main 10048 -> container targetPort 4040 (http)

## Env vars
- None set in chart (env map empty)

## Volumes/paths
- config: enabled, mountPath /config

## Probes
- liveness, readiness, startup: HTTP GET path "/"

## User/UID
- securityContext.container: runAsUser 0, runAsGroup 0, runAsNonRoot false, readOnlyRootFilesystem false
