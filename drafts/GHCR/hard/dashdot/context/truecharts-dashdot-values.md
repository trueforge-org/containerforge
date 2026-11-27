# TrueCharts dashdot values.yaml

Source URL: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/dashdot/values.yaml (fetched 2026-11-27)

## What it is
TrueCharts Helm chart values for dashdot. Chart version 15.0.0 (see truecharts-dashdot-chart.md).

## Image
- repository: `ghcr.io/mauricenino/dashdot`
- tag: `6.3.4@sha256:434a54d2937411a06b09c50e55709cc7d3b092c0fe173a9e5c986f9b5a33c7c6`
- pullPolicy: IfNotPresent

## Security context (chart default)
- runAsNonRoot: false, runAsUser: 0, runAsGroup: 0
- readOnlyRootFilesystem: false
- privileged: true, allowPrivilegeEscalation: true
- capabilities add: SYS_ADMIN, SYS_RAWIO

## Ports
- service.main.ports.main: port 10044, protocol http
- Env `DASHDOT_PORT` = `{{ .Values.service.main.ports.main.port }}` (i.e. 10044 in chart)

## Probes (all http, path /)
- liveness, readiness, startup

## Env (set by chart)
| Name | Value |
| --- | --- |
| DASHDOT_PORT | templated from service port (10044) |

Commented-out (user-defined) examples, all optional: DASHDOT_WIDGET_LIST, DASHDOT_ACCEPT_OOKLA_EULA, DASHDOT_USE_IMPERIAL, DASHDOT_DISABLE_INTEGRATIONS, DASHDOT_SHOW_HOST, DASHDOT_ALWAYS_SHOW_PERCENTAGES, DASHDOT_FS_TYPE_FILTER, DASHDOT_FS_DEVICE_FILTER, DASHDOT_FS_VIRTUAL_MOUNTS, DASHDOT_OS_*, DASHDOT_ENABLE_CPU_TEMPS, DASHDOT_CPU_*, DASHDOT_STORAGE_*, DASHDOT_ENABLE_STORAGE_SPLIT_VIEW, DASHDOT_RAM_*, DASHDOT_USE_NETWORK_INTERFACE, DASHDOT_SPEED_TEST_INTERVAL, DASHDOT_NETWORK_*, DASHDOT_OVERRIDE_* (OS, ARCH, CPU_*, RAM_*, NETWORK_*, STORAGE_*).

## Persistence (hostPath, read-only)
| Name | hostPath | mountPath | readOnly |
| --- | --- | --- | --- |
| host-mnt | `/` | `/mnt/host` | true |
| mem | `/dev/mem` | `/dev/mem` | true |

## Gotchas
- Chart sets host-level access: privileged, SYS_ADMIN, SYS_RAWIO, root, host `/` and `/dev/mem` (as chart defaults).
- Chart `kubeVersion` >=1.33.0-0 (Chart.yaml).
