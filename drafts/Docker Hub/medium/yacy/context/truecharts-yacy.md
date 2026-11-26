# TrueCharts: yacy chart (values.yaml)

**Source URL(s):** https://github.com/trueforge-org/truecharts/tree/master/charts/stable/yacy (fetched via https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/yacy/values.yaml)
**Fetched:** 2026-11-26

## Image
- `docker.io/yacy/yacy_search_server:latest`, pinned by digest `sha256:4077e9d85ea13e3d2a29b63add60b109ccced191bebfc169d422dd50fca44c41`, IfNotPresent. Chart uses the rolling `latest` tag.

## Services and ports
- `main` service: port 8090, protocol http, targetPort 8090.
- `https` service: enabled, port 8443, protocol tcp, targetPort 8443 (declared separately from main).

## Env
None defined.

## Persistence
- `appdata`: enabled, mounted at `/opt/yacy_search_server/DATA`. No readOnly or size.

## Security context (container)
- runAsUser 0, runAsGroup 0, readOnlyRootFilesystem false. Runs as root with writable rootfs.

## Probes
None defined.

## Other
- Schema reference `./values.schema.json`.
- The plan keeps the data at `/config` (not the chart's DATA mount path) and uses UID 568 with a read-only rootfs.
