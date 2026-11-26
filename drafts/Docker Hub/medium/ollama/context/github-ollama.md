# GitHub: ollama/ollama (Dockerfile at v0.40.16, README on main)

## Source URL(s) + date
- https://raw.githubusercontent.com/ollama/ollama/v0.40.16/Dockerfile (2026-11-26)
- https://raw.githubusercontent.com/ollama/ollama/main/README.md (2026-11-26)
- https://github.com/ollama/ollama/blob/v0.40.16/Dockerfile (same file as raw, not parsed separately)
- https://api.github.com/repos/ollama/ollama/releases/latest: 403, failed

## What it is
Go LLM runner (ollama CLI and server). Upstream Dockerfile builds llama-server variants (CPU, CUDA 12/13, ROCm 7.2, Vulkan, JetPack) and a Go binary, then a ubuntu:24.04 final stage.

## Dockerfile structure (v0.40.16)
- Global ARGs: `FLAVOR=${TARGETARCH}`, `ROCMVERSION=7.2.1`, `JETPACK5VERSION=r35.4.1`, `JETPACK6VERSION=r36.4.0`, `CMAKEVERSION=3.31.2`, `NINJAVERSION=1.12.1`, `VULKANVERSION=1.4.321.1`.
- Builder bases: `rocm/dev-almalinux-8` (amd64), `almalinux:8` (arm64); CMake and Ninja fetched from GitHub releases.
- GPU/CPU llama-server stages (cpu-deps, cuda-12-deps 12.8, cuda-13-deps 13.0, rocm-7-deps, vulkan-deps, jetpack5/6).
- Go build stage `build` (`GOFLAGS -ldflags=-w -s`, `CGO_ENABLED=1`) -> `/bin/ollama`.
- Final stage: `FROM ubuntu:24.04`. Copies `/lib/ollama` -> `/usr/lib/ollama`; `/bin/ollama` into image.

## Final stage directives (verbatim values)
| Directive | Value |
| --- | --- |
| ENV PATH | /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin |
| ENV LD_LIBRARY_PATH | /usr/local/nvidia/lib:/usr/local/nvidia/lib64 |
| ENV NVIDIA_DRIVER_CAPABILITIES | compute,utility |
| ENV NVIDIA_VISIBLE_DEVICES | all |
| ENV OLLAMA_HOST | 0.0.0.0:11434 |
| EXPOSE | 11434 |
| ENTRYPOINT | ["/bin/ollama"] |
| CMD | ["serve"] |

- No USER directive (runs as root). No VOLUME, no HEALTHCHECK.
- Build args: APT_MIRROR, APT_PORTS_MIRROR (default archive.ubuntu.com / ports.ubuntu.com), OLLAMA_MLX_BUILD_JOBS, OLLAMA_MLX_NVCC_THREADS=2, MLX_CUDA_RAM_MB, CUDA12VERSION=12.8, CUDA13VERSION=13.0.

## Install/build deps
- Go toolchain at /usr/local/go, cmake 3.31.2, ninja 1.12.1, gcc-toolset-13, CUDA toolkits, ROCm 7.2.1, Vulkan SDK 1.4.321.1, OpenBLAS.

## Runtime deps (final stage)
- Apt package list in final stage (lines 321-340 of Dockerfile) not extracted in this pass; re-read before writing the build.

## Version/asset naming
- Tag `v0.40.16` in the fetched Dockerfile URL. Latest API release call returned 403.

## Arch
- amd64 (rocm base, CUDA) and arm64 (almalinux, jetpack) stages in one Dockerfile. Final image built per TARGETARCH.

## README (main) facts
- Env vars seen in README: OLLAMA_HOST, OLLAMA_MODELS, OLLAMA_KEEP_ALIVE, OLLAMA_CONTEXT_LENGTH, OLLAMA_NUM_PARALLEL, OLLAMA_MAX_LOADED_MODELS, OLLAMA_MAX_QUEUE, OLLAMA_ORIGINS, OLLAMA_FLASH_ATTENTION, OLLAMA_KV_CACHE_TYPE, OLLAMA_CHANNEL, OLLAMA_NO_CLOUD (full list in FAQ, see ollama-docs.md).

## Gotchas
- Dockerfile version (v0.40.16) differs from the chart pin (0.40.18). Dockerfile for 0.40.18 was not fetched.
- The Dockerfile uses ubuntu:24.04 final stage (upstream). ContainerForge base is 26.04 (per plan).
