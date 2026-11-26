# mudler/LocalAI Dockerfile (pinned commit)

**Source:** https://raw.githubusercontent.com/mudler/LocalAI/56f44d448ca585642de4ca13f0521c3096268f1f/Dockerfile (fetched 2026-11-26; blob URL in urls.txt is the same file)

## Global ARGs (pre-stage)
| ARG | Default |
|---|---|
| IMAGE_TYPE | extras |
| BASE_IMAGE | ubuntu:22.04 |
| GRPC_BASE_IMAGE | = BASE_IMAGE |
| INTEL_BASE_IMAGE | = BASE_IMAGE |

## Stages
| Stage | Parent | Purpose |
|---|---|---|
| requirements-core | BASE_IMAGE | apt toolchain, CMake, Go, protoc plugins, CA certs, OpenBLAS |
| requirements-extras | requirements-core | uv, Rust, Python, espeak, grpcio-tools |
| requirements-drivers | requirements-${IMAGE_TYPE} | driver install by BUILD_TYPE (vulkan, cublas, clblas, hipblas) |
| intel | INTEL_BASE_IMAGE | Intel apt key/source workaround |
| grpc | GRPC_BASE_IMAGE | builds gRPC into /opt/grpc |
| builder-base | requirements-drivers | ENV/ARGs, protoc 27.1 |
| builder | builder-base | copies gRPC, `make prepare` + `make build` |
| devcontainer | builder-base | dev tools, source mounted |
| final (unnamed) | requirements-drivers | published image |

## ARG defaults by stage
| Stage | ARG: default |
|---|---|
| requirements-core | GO_VERSION 1.22.6; CMAKE_VERSION 3.26.4; CMAKE_FROM_SOURCE false |
| requirements-drivers | BUILD_TYPE (none); CUDA_MAJOR_VERSION 12; CUDA_MINOR_VERSION 0; SKIP_DRIVERS false |
| grpc | GRPC_VERSION v1.65.0; GRPC_MAKEFLAGS "-j4 -Otarget" |
| builder-base | GO_TAGS "tts p2p"; LD_FLAGS "-s -w" |
| final | IMAGE_TYPE extras; CUDA_MAJOR_VERSION 12; FFMPEG, BUILD_TYPE, TARGETARCH, EXTRA_BACKENDS, MAKEFLAGS unset |

## Packages
- requirements-core apt: build-essential, ccache, ca-certificates, curl, libssl-dev, git, git-lfs, unzip, upx-ucl, libopenblas-dev, cmake
- extras: uv, Rust (rustup), espeak-ng, espeak, python3-pip, python-is-python3, python3-dev, llvm, python3-venv, grpcio-tools
- vulkan: vulkan-sdk (LunarG repo); cublas: cuda-nvcc, libcublas-dev, libcufft-dev, libcurand-dev, libcusparse-dev, libcusolver-dev; clblas: libclblast-dev; hipblas: hipblas-dev, rocblas-dev
- builder-base: protoc 27.1 zip (amd64/arm64) into /usr/local/bin
- final: optional ffmpeg; espeak-ng (condition compares "extras " with trailing space, may never match)

## ENV (final stage)
- DEBIAN_FRONTEND=noninteractive
- EXTERNAL_GRPC_BACKENDS: backend:run.sh pairs under /build/backend/python/ (coqui, transformers, rerankers, autogptq, bark, diffusers, faster-whisper, kokoro, vllm, exllama2)
- PATH += /root/go/bin, /usr/local/go/bin, /usr/local/cuda/bin, /opt/rocm/bin, /root/.cargo/bin
- NVIDIA_DRIVER_CAPABILITIES=compute,utility; NVIDIA_VISIBLE_DEVICES=all; NVIDIA_REQUIRE_CUDA=cuda>=${CUDA_MAJOR_VERSION}.0
- REBUILD=false; HEALTHCHECK_ENDPOINT=http://localhost:8080/readyz

## Runtime config
- USER: root (explicit; no UID defined)
- WORKDIR /build
- EXPOSE 8080
- VOLUME /build/models
- ENTRYPOINT ["/build/entrypoint.sh"], no CMD
- HEALTHCHECK: interval 1m, timeout 10m, retries 10, `curl -f ${HEALTHCHECK_ENDPOINT}`
- SHELL /bin/bash in final stage

## Paths
- /build (workdir), /build/sources, /build/local-ai (binary), /build/models, /build/backend/python/*
- /opt/grpc (copied to /usr/local), /usr/local/share/ca-certificates (from custom-ca-certs/*)

## Build flow
- builder: `make prepare`, `make build`; cublas/hipblas set SKIP_GRPC_BACKEND (skips llama-cpp avx variants).
- final: COPY . ., copies sources, gRPC, binary; `make prepare-sources`.
- Python backends built via `make -C backend/python/<name>` only if IMAGE_TYPE=extras and EXTRA_BACKENDS empty or matching.

## Gotchas
- Default base ubuntu:22.04; runs as root (not rootless by default; app-level UID handling per docs).
- CMake source-build branch uses `${CMAKE_FROM_SOURCE}}` (extra brace), likely never triggers.
