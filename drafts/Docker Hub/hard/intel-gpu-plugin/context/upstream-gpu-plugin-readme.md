# GPU plugin README (cmd/gpu_plugin)

Source URL(s): https://raw.githubusercontent.com/intel/intel-device-plugins-for-kubernetes/main/cmd/gpu_plugin/README.md. Fetched 2026-11-26.

## Device paths
- Mounts DRM nodes under `/dev/dri` (card*, renderD128 etc.); by-path symlinks in `/dev/dri/by-path/`.
- Individually mounted symlinks lose PCI info. SR-IOV: only VFs given to containers.
- Multi-GPU: container may get non-renderD128 device; VA-API/QSV need explicit device arg. `render-device.sh` prints the Nth device.

## Resource names
- `gpu.intel.com/i915` (legacy i915 KMD), `gpu.intel.com/xe` (xe KMD), `gpu.intel.com/monitoring`.
- Deprecated: `i915_monitoring`, `xe_monitoring`.

## Flags (default)
| Flag | Default | Notes |
| --- | --- | --- |
| `-shared-dev-num` | 1 | >1 = several containers per GPU |
| `-enable-monitoring` | off | |
| `-monitoring-mode` | single | or `split` |
| `-health-management` | off | needs Level-Zero sidecar |
| `-xpumd-endpoint` | "" | e.g. `/run/xpumd/intelxpuinfo.sock`; exclusive with health-management |
| `-xpumd-unhealthy-severity` | critical | warning, critical, failed |
| `-wsl` | off | needs Level-Zero sidecar |
| `-allow-ids` / `-deny-ids` | "" | PCI device IDs; mutually exclusive |
| `-allocation-policy` | none | balanced, packed |
| `-bypath` | single | none, all |
| temp flags | - | `-temp-limit`, `-gpu-temp-limit`, `-memory-temp-limit` (default 100C); n/a with xpumd |

- Logging flags common to all plugins; `-h` lists them.

## Modes
- by-path `single`: individual symlinks (known pytorch issues); `none`: no symlinks (docker privileged style); `all`: whole by-path dir.

## NFD
- Node selector on NFD Intel GPU label. Kustomize: `deployments/nfd`, `deployments/nfd/overlays/node-feature-rules`, `deployments/gpu_plugin/overlays/nfd_labeled_nodes`.

## Host paths / privileges
- xpumd overlay (`deployments/gpu_plugin/overlays/xpumd`): mounts `/run/xpumd` read-only, sets `-xpumd-endpoint` and `-enable-monitoring`.
- Non-root: node DAC rules must allow device plugin socket creation and kubelet registration; securityContext needs runAsUser/runAsGroup.
- SR-IOV configured by admin.

## Health
- Default all devices Healthy. Level-Zero sidecar / xpumd report Unhealthy on memory/PCI/temperature/WARNING+ domains.

## CDI
- Supported, no benefit yet. CRI-O 1.24+, containerd 1.7+, Docker 25+. K8s 1.28 needs `DevicePluginCDIDevices` gate; default from 1.29.

## KMD/UMD
- KMDs: out-of-tree i915 (Flex/Max), upstream i915 (older client), xe. UMDs in container must match node KMD.

## Verification
- `status.allocatable.gpu\.intel\.com/i915`; demo `intelgpu-job.yaml` (intel-opencl-icd, clinfo).
- Missing resource -> pod Pending "Insufficient gpu.intel.com/i915".
