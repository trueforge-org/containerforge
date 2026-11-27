# Source: utkuozdemir/nvidia_gpu_exporter Dockerfile (commit a6712afb)

Source URL(s) + date: https://raw.githubusercontent.com/utkuozdemir/nvidia_gpu_exporter/a6712afbab9ad620e7cc7897e11cd084147b5e96/Dockerfile (fetched 2026-11-27; blob variant = same)

## Build
- Single stage: `FROM gcr.io/distroless/base-nossl-debian13:latest@sha256:3a2dbf10c2fdafe5865e2b03a4a3b9b23f2e280229a81730415379b76dc70592`.
- Comment: needs glibc base because nvidia-smi injected by NVIDIA runtime needs libc and loader; scratch/static not possible.
- `ARG TARGETPLATFORM`; `COPY ${TARGETPLATFORM}/nvidia_gpu_exporter /usr/bin/nvidia_gpu_exporter` (build context provides per-arch binary dirs).
- `USER 65534:65534` (numeric, kubelet runAsNonRoot check).
- `EXPOSE 9835`.
- `ENTRYPOINT ["/usr/bin/nvidia_gpu_exporter"]`. No CMD.

## Runtime deps
- glibc (distroless base-nossl-debian13). Host-injected nvidia-smi and libnvidia-ml.

## Ports
- 9835.

## User/UID
- 65534:65534 numeric.

## Gotchas
- Upstream relies on NVIDIA Container Toolkit (`--gpus all`, env NVIDIA_DRIVER_CAPABILITIES=utility) to inject nvidia-smi and libraries.
- Binary is copied from a per-TARGETPLATFORM directory (build context layout), not built from source here.
