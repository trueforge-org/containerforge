# Upstream Dockerfile: open-webui (ui image, main and pinned commit)

Source URL(s) + date:
- https://raw.githubusercontent.com/open-webui/open-webui/main/Dockerfile (2026-11-27)
- https://raw.githubusercontent.com/open-webui/open-webui/0666e59/Dockerfile (raw variant of pinned blob, 2026-11-27): byte-identical to main

What it is: multi-stage build of the Open WebUI frontend (Node) and backend (Python). Used by the chart as `ghcr.io/open-webui/open-webui`.

Build args (defaults):
- USE_CUDA=false, USE_OLLAMA=false, USE_SLIM=false, USE_PERMISSION_HARDENING=false
- USE_CUDA_VER=cu128
- USE_EMBEDDING_MODEL=sentence-transformers/all-MiniLM-L6-v2
- USE_RERANKING_MODEL="", USE_AUXILIARY_EMBEDDING_MODEL=TaylorAI/bge-micro-v2
- USE_TIKTOKEN_ENCODING_NAME=cl100k_base
- BUILD_HASH=dev-build, BUILD_CHANNEL=unknown
- UID=0, GID=0 ("non-root configurations are untested")

Stages:
1. `build`: `node:22-alpine3.20`, `npm ci --force`, `npm run build`; chown/chmod of `/app/backend` and static dir for group 0.
2. `base`: `python:3.12-slim-trixie`. Installs curl, jq, ca-certificates; if not slim adds git, build-essential, pandoc, gcc, libmariadb-dev, ffmpeg, libsm6, libxext6; zstd if USE_OLLAMA. Python deps via uv 0.12.10 (`ghcr.io/astral-sh/uv:0.12.10`) from `requirements*.lock` with `--require-hashes`. Torch CPU wheel index (or CUDA index). Pre-downloads embedding, whisper, and tiktoken models when not slim.
3. Optional Ollama install via `curl https://ollama.com/install.sh` when USE_OLLAMA=true.

Runtime (final stage):
- `ENV`: PORT=8080, ENV=prod, OLLAMA_BASE_URL="/ollama", OPENAI_API_BASE_URL="", OPENAI_API_KEY="", WEBUI_SECRET_KEY="", SCARF_NO_ANALYTICS=true, DO_NOT_TRACK=true, ANONYMIZED_TELEMETRY=false, WHISPER_MODEL=base, WHISPER_MODEL_DIR=/app/backend/data/cache/whisper/models, RAG_EMBEDDING_MODEL, SENTENCE_TRANSFORMERS_HOME=/app/backend/data/cache/embedding/models, TIKTOKEN_CACHE_DIR=/app/backend/data/cache/tiktoken, HF_HOME=/app/backend/data/cache/embedding/models, DOCKER=true, WEBUI_BUILD_HASH
- `WORKDIR /app/backend`, `HOME=/root`
- Creates user `app` with UID/GID if UID != 0
- `/root/.cache/chroma` telemetry id file
- `EXPOSE 8080`
- `HEALTHCHECK CMD curl --silent --fail http://localhost:${PORT:-8080}/health | jq -ne 'input.status == true' || exit 1`
- `USER $UID:$GID` (default 0:0)
- `CMD ["bash", "start.sh"]`

Volumes: none declared. Data written under `/app/backend/data` (chart mounts there).

Gotchas:
- Frontend build node 22; backend python 3.12.
- USE_SLIM cannot combine with USE_CUDA or USE_OLLAMA (build fails).
- USE_PERMISSION_HARDENING sets group 0 ownership on /app and /root for arbitrary UIDs.
- Non-root (UID != 0) is documented as untested.
