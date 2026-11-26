# TrueCharts chart: restic-rest-server

Source URL(s) + fetch date (2026-11-26):
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/restic-rest-server (tree, not fetched directly)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/restic-rest-server/values.yaml (fetched)

## Image
- repository `docker.io/restic/rest-server`, tag `0.15.0@sha256:5922067eb6f1ed8a632bc56101677ab4968a3b88a28806423e95ebb5eeecdebb`, pullPolicy IfNotPresent.

## Ports
- port 8000 tcp (targetPort 8000).

## Persistence
- `data` mountPath `/data`.

## securityContext (container)
- readOnlyRootFilesystem false, runAsUser 0, runAsGroup 0.

## Env vars
- `OPTIONS` = "" (empty).

## Probes
- None. (Chart does not use the /healthz endpoint added in v0.15.0.)
