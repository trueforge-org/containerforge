# Context: nvidia-gpu-exporter

| Source URL | File |
| --- | --- |
| https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/nvidia-gpu-exporter/values.yaml + Chart.yaml | truecharts-nvidia-gpu-exporter.md |
| https://raw.githubusercontent.com/utkuozdemir/nvidia_gpu_exporter/a6712afb.../Dockerfile (+ blob variant) | nvidia-gpu-exporter-dockerfile.md |
| https://raw.githubusercontent.com/utkuozdemir/nvidia_gpu_exporter/master/README.md | nvidia-gpu-exporter-readme.md |
| https://github.com/utkuozdemir/nvidia_gpu_exporter/releases/expanded_assets/v1.19.0 | nvidia-gpu-exporter-release-v1.19.0-assets.md |

Skipped: https://github.com/utkuozdemir/nvidia_gpu_exporter (repo root, covered by raw README and Dockerfile); blob Dockerfile (duplicate of raw).
No Docker Hub REQUIRED URL in urls.txt (GHCR image); chart image is on GHCR.

Failures: none.

## plan.md corrections
- No edit made. UNVERIFIED conflict: chart image tag is `2.0.0` (appVersion 2.0.0), while plan.md (lines 8-13) uses upstream release `v1.19.0` as the version to build. Not resolvable from fetched sources; the chart may track a different image version scheme.
- Confirmation (not a correction): chart args confirm flag names `--web.listen-address`, `--web.telemetry-path`, `--collect.backend`, `--nvidia-smi-command`, `--log.level`, `--log.format` (plan.md line 18 said the listen-address flag name default is UNVERIFIED; the flag name is now seen in the chart, default still unverified).
