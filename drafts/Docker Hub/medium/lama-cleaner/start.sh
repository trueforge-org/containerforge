#!/usr/bin/env bash

# caches live under /config (TORCH_HOME and HF_HOME are set in the Dockerfile)
mkdir -p /config/cache/torch /config/cache/huggingface

cd /app || exit 1
# flags from the IOPaint docs (iopaint start --model=lama --device=cpu --port=8080)
# UNVERIFIED: --host=0.0.0.0 is not in the docs; confirm with `iopaint start --help` in the built image
exec /app/venv/bin/iopaint start \
  --model="${MODEL:-lama}" \
  --device=cpu \
  --host=0.0.0.0 \
  --port=8080
