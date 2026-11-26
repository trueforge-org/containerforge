# mudler/LocalAI README

**Source:** https://raw.githubusercontent.com/mudler/LocalAI/master/README.md (fetched 2026-11-26)

## What it is
- Self-hosted AI server, MIT license (name, logo and mascot reserved).
- Runs open models for chat, images, speech, video, music, embeddings, reranking.
- OpenAI- and Anthropic-compatible API; ElevenLabs-style TTS.
- More than 80 backends; each is a separate image, pulled on demand per model type.
- Mostly Go, with C/C++/GGML and some Python backends.

## Install / build
- Script: `curl -sSL https://localai.io/install.sh | sh`, then `local-ai`.
- Build from source: README only links to docs; no steps given.

## Runtime deps
- Backends fetched at runtime from Backend Gallery; needs network for first use of each model type unless backends are pre-seeded.
- Distributed mode needs PostgreSQL and NATS (optional).

## Entrypoint / flags
- Start: `local-ai`. Run a model: `local-ai run <model>` (sources: gallery name, `huggingface://`, `ollama://`, `oci://`).
- Other CLI: `local-ai models list`, `local-ai chat --model <name>`, `local-ai benchmark`.

## Ports
- 8080 (UI + API).

## Arch / GPU
- NVIDIA CUDA 12/13, AMD ROCm, Intel oneAPI/SYCL, Apple Silicon Metal, Vulkan, Jetson L4T, CPU.
- x86-64 and ARM64.

## Gotchas
- README does not list env vars, in-container paths, config file names, or healthcheck. See `localai-docs-containers.md`.
