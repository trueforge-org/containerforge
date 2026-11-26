# TrueCharts chart: rickroll

Source URL(s) + fetch date (2026-11-26):
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/rickroll (tree, not fetched directly)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/rickroll/values.yaml (fetched)

## Image
- repository `docker.io/modem7/docker-rickroll`, tag `latest@sha256:e0764d70fa3ec3a851bf3773a235e185064095777a0de1c479a09c6c34a8c5f4`, pullPolicy IfNotPresent.

## Ports
- service main http, port 10289 (chart), targetPort 8080.

## Persistence
- None defined.

## securityContext (container)
- runAsNonRoot false, readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0.

## Env vars
- TITLE "Rickroll", HEIGHT "100vh", WIDTH "100%", HEADLINE "".

## Probes
- liveness, readiness and startup all of type http (no path or port detail in the fetched text).
