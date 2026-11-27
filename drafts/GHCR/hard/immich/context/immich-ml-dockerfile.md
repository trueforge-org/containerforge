# immich machine-learning Dockerfile (upstream)

Source URL(s) + date: https://raw.githubusercontent.com/immich-app/immich/v3.4.1/machine-learning/Dockerfile · fetched 2026-11-27 (first ~3000 chars only)

## Structure
- `ARG DEVICE=cpu`; per-device builder stages: cpu, openvino, cuda, armnn, rknn (plus others not captured).
- Base: python:3.13-slim-trixie (digest pinned) for cpu/openvino; cuda uses python:3.13-slim-bookworm; armnn python:3.13-trixie; rknn python:3.12-slim-trixie.
- uv 0.8.15 copied from ghcr.io/astral-sh/uv; `uv sync --frozen --extra openvino ...`.
- openvino stage builds onnxruntime v1.30.0 from source (renovate-annotated ARG ONNXRUNTIME_VERSION), `--use_openvino CPU`, repacks wheel with openvino libs, patchelf rpath `$ORIGIN`.
- armnn stage downloads ArmNN-linux-aarch64.tar.gz (ARMNN_VERSION v26.07) from GitHub releases.
- rknn stage warns 25GiB+ disk needed.

## Gotchas
- Build is heavy (onnxruntime from source for openvino); not practical for a minimal rebuild.
- Remaining stages and final runtime stage not captured in the fetch.
