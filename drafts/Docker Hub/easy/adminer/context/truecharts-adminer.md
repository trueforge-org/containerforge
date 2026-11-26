# TrueCharts: adminer chart (values.yaml)

**Source URL(s):** https://github.com/trueforge-org/truecharts/tree/master/charts/stable/adminer (fetched via https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/adminer/values.yaml)
**Fetched:** 2026-11-26

## Image
- Repository `adminer`, tag `latest`, pinned to a sha256 digest (037125c2bc48…8dfd), pull policy IfNotPresent.

## Service and ports
- Service `main`, port name `main`: service port **18080**, protocol http, container target port **8080**.

## Env
- `ADMINER_DESIGN` = "" (empty)
- `ADMINER_PLUGINS` = "" (empty)

## Persistence
None defined.

## Security context (container level)
- `readOnlyRootFilesystem: false`
- `runAsNonRoot: false`
- `runAsUser: 0`, `runAsGroup: 0`
- Container runs as root with writable root filesystem.

## Probes
Liveness, readiness and startup probes all type `http`, path `/`.

## Other
- No resource limits, ingress or extra volumes.
- Workload defined under `workload.main.podSpec.containers.main`.
- Chart's values.yaml references `./values.schema.json`.
