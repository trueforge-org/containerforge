# TrueCharts chart: nvidia-gpu-exporter

Source URL(s) + date: https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/nvidia-gpu-exporter/{Chart.yaml,values.yaml} (fetched 2026-11-27)

## What it is
- Chart `nvidia-gpu-exporter` v9.0.0, appVersion 2.0.0, category metrics.
- Depends on `common` 32.8.5 (oci://oci.trueforge.org/truecharts) per Chart.yaml pattern.

## Image
- repository: `ghcr.io/utkuozdemir/nvidia_gpu_exporter`
- tag: `2.0.0@sha256:bd7ca0426cbfd4a5e5b33625b873541c5da58c52569f9e141db8e76c7d3e9256`
- pullPolicy: IfNotPresent
- NOTE: tag 2.0.0 differs from upstream release v1.19.0 used in plan.md (see README corrections).

## Workload
- type: DaemonSet, container `main`.
- args: `--web.listen-address :<port>`, `--web.telemetry-path <metricsEndpoint>`, `--collect.backend <collectBackend>`, `--nvidia-smi-command nvidia-smi`, `--log.level <logs.general.level>`, `--log.format <logs.general.format>`.
- Probes: liveness and readiness HTTP on path `{{ metricsEndpoint }}` port main; startup tcp port main.

## Values
| Key | Default |
| --- | --- |
| metricsEndpoint | /metrics |
| collectBackend | nvml |
| logs.general.level | info |
| logs.general.format | logfmt |

## Service / ports
- service.main.ports.main: port 9835, protocol http.

## Metrics
- metrics.main: servicemonitor, endpoint port main, path {{ metricsEndpoint }}.

## Persistence (hostPath, readOnly)
| Name | hostPath | mountPath |
| --- | --- | --- |
| nviaictl | /dev/nvidiactl | /dev/nvidiactl |
| nvidia0 | /dev/nvidia0 | /dev/nvidia0 |
| nvidiasmi | /usr/bin/nvidia-smi | /usr/bin/nvidia-smi |
| libnvidiamlso | /usr/lib/x86_64-linux-gnu/libnvidia-ml.so | same |
| libnvidiamlso1 | /usr/lib/x86_64-linux-gnu/libnvidia-ml.so.1 | same |

## Security
- container: privileged true; readOnlyRootFilesystem false; runAsUser 0; runAsGroup 0.

## Gotchas
- Chart mounts host NVIDIA device nodes and binaries directly instead of relying on the NVIDIA container toolkit.
- Chart runs privileged as root.
