# TrueCharts chart: dockovpn

Source URL(s) + fetch date:
- https://github.com/trueforge-org/truecharts/tree/master/charts/stable/dockovpn (chart directory; not fetched directly)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/dockovpn/values.yaml
- Fetched 2026-11-26

## Container image (values.yaml)
- `docker.io/alekslitvinenk/openvpn`, tag `v1.14.0@sha256:8f3424e3de810169fcd5c770ad723112f5671fcbeb635215612379f7941fc0fe`, pullPolicy IfNotPresent.

## Services and ports
- `service.main`: name `main`, port 8080 (config download). No protocol/targetPort given.
- `service.vpn`: name `vpn`, port 1194, protocol templated from `HOST_TUN_PROTOCOL` (resolves to udp). No targetPort.

## Persistence
- `config`: mountPath `/opt/Dockovpn_data`, enabled true, no type.

## Security context (container)
- readOnlyRootFilesystem false; runAsNonRoot false; runAsUser 0; runAsGroup 0; allowPrivilegeEscalation true.
- capabilities add: `NET_ADMIN`, `NET_RAW`, `MKNOD`. Drop: not specified. privileged: not specified.
- fsGroup / podSecurityContext: not specified.

## Devices
- No device entries; `/dev/net/tun` is not mounted by the chart.

## Env vars (main container)
- HOST_ADDR `vpn.example.com`; HOST_CONF_PORT = service main port (8080); HOST_TUN_PROTOCOL `udp` (comment: only UDP supported); HOST_TUN_PORT = service vpn port (1194).

## Probes
- liveness, readiness and startup all disabled.
