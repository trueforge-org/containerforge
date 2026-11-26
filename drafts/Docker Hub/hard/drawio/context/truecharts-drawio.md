# TrueCharts chart: drawio

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/drawio (directory not fetched)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/drawio/values.yaml
- Fetched 2026-11-26

## Container image (values.yaml)
- `docker.io/jgraph/drawio`, tag `32.7.7@sha256:9911eb718f41ad68bd5f348f1c8ae4c54e032580d12b1c0a6bb65982f4e04576`, pullPolicy IfNotPresent. (Draft says 32.7.4.)

## Service
- `service.main`, port `main`: port 10214, targetPort 8080.

## Persistence
- None defined.

## Security context
- readOnlyRootFilesystem false; runAsNonRoot false; runAsUser 0; runAsGroup 0. privileged, allowPrivilegeEscalation, fsGroup not specified.

## Env vars
- None (`env: {}`).

## Probes
- liveness, readiness, startup: type http, path `/`.

## Dependencies
- None.
