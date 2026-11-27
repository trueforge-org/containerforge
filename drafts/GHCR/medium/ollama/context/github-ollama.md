# Upstream: ollama/ollama (repo README and Dockerfile)

Source URL(s) + date:
- https://raw.githubusercontent.com/ollama/ollama/main/README.md (2026-11-27)
- https://raw.githubusercontent.com/ollama/ollama/main/Dockerfile (2026-11-27)
- https://github.com/ollama/ollama (not fetched separately; README and Dockerfile used)

What it is: Ollama, run LLMs locally. Local REST API on port 11434.

Dockerfile (main, 13.4 KB, multi-stage):
- Build args: `FLAVOR=${TARGETARCH}`, `ROCMVERSION=7.2.1`, `CUDA12VERSION=12.8`, `CUDA13VERSION=13.0`
- Stages: base (`almalinux:8`, gcc-toolset-13 / clang), cpu-deps, cuda-12-deps, cuda-13-deps, rocm-7-deps, vulkan-deps, llama-server-*, build, image-archive, arm64-archive, amd64-archive, rocm
- Final: `FROM ubuntu:24.04`, apt installs `ca-certificates libvulkan1 libopenblas0` (APT_MIRROR build args, then reset to archive.ubuntu.com)
- Copies `/bin` into `/usr/bin`, `/lib/ollama` into `/usr/lib/ollama`
- `ENV PATH=...`, `LD_LIBRARY_PATH=/usr/local/nvidia/lib:/usr/local/nvidia/lib64`, `NVIDIA_DRIVER_CAPABILITIES=compute,utility`, `NVIDIA_VISIBLE_DEVICES=all`
- `ENV OLLAMA_HOST=0.0.0.0:11434`
- `EXPOSE 11434`
- `ENTRYPOINT ["/bin/ollama"]`, `CMD ["serve"]`
- No USER directive (runs as root), no VOLUME.

Models/data: model store at `/root/.ollama` (per Docker Hub README run example `-v ollama:/root/.ollama`).

Env vars (from Dockerfile): OLLAMA_HOST, LD_LIBRARY_PATH, NVIDIA_* as above. Other OLLAMA_* settings not in fetched files.

Ports: 11434/tcp.

Arch: amd64 and arm64 build paths; ROCm (amd64) and CUDA variants via stages and FLAVOR.

Gotchas:
- Runtime stage is ubuntu:24.04, not scratch or alpine.
- Chart's `ollama` image comes from Docker Hub `docker.io/ollama/ollama` (see dockerhub-ollama.md).
