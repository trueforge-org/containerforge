# TrueCharts lama-cleaner (chart 12.0.0)

## Source URL(s) + date
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/lama-cleaner/values.yaml (2026-11-26)
- https://raw.githubusercontent.com/trueforge-org/truecharts/master/charts/stable/lama-cleaner/Chart.yaml (2026-11-26)

## What it is
- Chart `version: 12.0.0`, `appVersion: 0.33.0`, `kubeVersion: '>=1.33.0-0'`, category `media`, train `stable`.
- Description: "Open-source inpainting tool powered by SOTA AI model."
- Library dep: `common` 32.8.5 (`oci://oci.trueforge.org/truecharts`).

## Images
| Role | Image | Tag |
| --- | --- | --- |
| CPU (`image`) | `docker.io/cwq1913/lama-cleaner` | `cpu-0.33.0@sha256:5011038046b50882281b418614b55f8f5db4ced31c42c297ede2d513c53ab105` |
| GPU (`gpuImage`, unused by main workload) | `docker.io/cwq1913/lama-cleaner` | `gpu-0.33.0@sha256:c52f131701d4c21eae1f898ee59cdc26c73ccbe45b6cb8e75bf4b60989dd5015` (`pullPolicy: Always`) |
- CPU `pullPolicy: IfNotPresent`.

## Command / app config (values `lamacleaner`)
| Key | Value |
| --- | --- |
| command (container `main`) | `lama-cleaner` |
| model | `lama` |
| input | "" |
| sd_run_local | false |
| hf_access_token | "" |
| sd_disable_nsfw | false |
| sd_cpu_text_encoder | false |
| sd_enable_xformers | false |
| debug | false |
- No `env:` block in workload; the `lamacleaner` keys are values only (no env mapping visible in fetched text).

## Ports
- service `main` / port `main`: 10604, `protocol: http`. Container port not set in chart.

## Volumes/paths
| Persistence | Mount |
| --- | --- |
| torch | `/root/.cache/torch` |
| huggingface | `/root/.cache/huggingface` |

## User/UID
- `securityContext.container`: `runAsUser: 0`, `runAsGroup: 0`, `runAsNonRoot: false`, `readOnlyRootFilesystem: false`.

## Gotchas
- Chart pins `0.33.0` (old `lama-cleaner` line, 2023-01-20 push). Docker Hub newest is `cpu-1.2.5` (2023-11-01).
- Chart's mounts are root cache paths; plan.md uses `/config`.
