# LocalAI container docs

**Source:** https://localai.io/docs/start/install/containers/ (fetched 2026-11-26; linked from localai.io/docs)

## Images
| Variant | Tag (Docker Hub `localai/localai`) |
|---|---|
| CPU | `latest` |
| NVIDIA CUDA 12 | `latest-gpu-nvidia-cuda-12` |
| NVIDIA CUDA 13 | `latest-gpu-nvidia-cuda-13` |
| AMD ROCm | `latest-gpu-hipblas` |
| Intel | `latest-gpu-intel` |
| Vulkan | `latest-gpu-vulkan` |
| Jetson CUDA 12 | `latest-nvidia-l4t-arm64` |
| Jetson CUDA 13 | `latest-nvidia-l4t-arm64-cuda-13` |

- Also on Quay: `quay.io/go-skynet/local-ai`.
- Tag prefixes: `master-` (dev), `v5.0.1-` (pinned).
- Podman needs `docker.io/` prefix.

## Ports
- 8080 (UI + API)

## Paths (in container)
| Path | Purpose | Flag | Env var |
|---|---|---|---|
| `/models` | models | `--models-path` | `LOCALAI_MODELS_PATH` |
| `/backends` | backends | `--backends-path` | `LOCALAI_BACKENDS_PATH` |
| `/configuration` | api_keys.json, external_backends.json, runtime_settings.json | `--localai-config-dir` | `LOCALAI_CONFIG_DIR` |
| `/data` | collections, add-ons, uploads, caches | `--data-path` | `LOCALAI_DATA_PATH` |

- Under /data: generated, upload, home, cache (incl. cache/sigstore), downloading.

## Env vars
| Name | Default | Purpose |
|---|---|---|
| LOCALAI_UID | unset | run as this uid (priority) |
| LOCALAI_GID | unset | group paired with uid |
| LOCALAI_RUN_AS_ROOT | false | run as root; disables sandboxed add-ons |
| HOME | /data/home (fallback) | cache workaround on 5.0.1 |
| LOCALAI_MODELS_PATH / BACKENDS_PATH / CONFIG_DIR / DATA_PATH | see paths table | path overrides |

## User / UID
- Entrypoint starts as root, fixes ownership, drops privileges.
- Selection order: LOCALAI_UID/GID -> shared non-root owner of /data and /models -> user `localai` (10001/10001).
- chown -R on the four folders when owned by another user; skipped with `--user`/runAsUser (folders must be writable already).
- Adds groups owning /dev/kvm, /dev/kfd, /dev/dri/*, /var/run/docker.sock (never gid 0).
- Rootless Podman: `--userns=keep-id:uid=10001,gid=10001`; GPUs add `--group-add keep-groups`.
- v5.0.1 and earlier: always uid 10001 unless LOCALAI_UID set; home /home/localai.
- Startup logs WARN if folders not writable.

## Healthcheck
- None documented on this page (Dockerfile sets one; see `mudler-localai-dockerfile.md`).

## Run
- `docker run -d --restart unless-stopped --init -p 8080:8080` + four `-v` mounts.
- Read-only root: `--read-only --tmpfs /tmp` (not CI-tested per docs).

## GPU flags
| GPU | Docker | Podman |
|---|---|---|
| NVIDIA | `--gpus all` | `--device nvidia.com/gpu=all` |
| AMD | `--device=/dev/kfd --device=/dev/dri` | `--device rocm.com/gpu=all` |
| Intel | `--device=/dev/dri` | `--device gpu.intel.com/all` |
| Vulkan | `--device=/dev/dri` (NVIDIA: `--gpus all`) | `--device=/dev/dri` |
| Jetson | `--runtime nvidia --gpus all` | not listed |

- NVIDIA needs NVIDIA Container Toolkit (1.14+ recommended).
- Compose NVIDIA: deploy.resources.reservations.devices driver nvidia, count all, capabilities [gpu]; CDI alt driver `nvidia.com/gpu`.

## Quick start
- `curl -fsSL https://localai.io/install/docker-compose.yaml -o docker-compose.yaml && docker compose up -d`
- Compose volumes: localai-models, localai-backends, localai-data, localai-configuration.
