# g0ldyy/comet Dockerfile (pinned a3b75ecbefc494747c30ab484ff86c07c61585f0)
Source URL(s): https://raw.githubusercontent.com/g0ldyy/comet/a3b75ecbefc494747c30ab484ff86c07c61585f0/Dockerfile (fetched 2026-11-27)

## Build (multi-stage)
- uv stage: `FROM ghcr.io/astral-sh/uv:0.11.32 AS uv`
- rust toolchain stage: `FROM rust:1.97.1-slim-trixie AS rust-toolchain`
- builder: `FROM python:3.13-slim-trixie`; copies uv/uvx to /bin, cargo+rustup from rust stage (CARGO_HOME=/usr/local/cargo, RUSTUP_HOME=/usr/local/rustup).
- builder apt: gcc, git, libc6-dev, make (--no-install-recommends).
- WORKDIR /app; COPY pyproject.toml uv.lock; `uv sync --frozen --no-install-project` with cache mount /root/.cache/uv.
- runtime: `FROM python:3.13-slim-trixie`; apt: libgcc-s1, libjemalloc2, libstdc++6, tzdata.
- COPY --from=builder /app/.venv /app/.venv; COPY comet ./comet.

## Runtime
- ENTRYPOINT ["python", "-m", "comet.main"]
- HEALTHCHECK: `python -m comet.healthcheck` (30s interval, 5s timeout, 10s start, 3 retries)
- No EXPOSE, no USER directive (runs as root in image).

## Env (image)
| Name | Value |
| --- | --- |
| TZ | UTC |
| PATH | /app/.venv/bin:$PATH |
| PYTHONDONTWRITEBYTECODE | 1 |
| PYTHONUNBUFFERED | 1 |
| PYTHONMALLOC | malloc |
| LD_PRELOAD | libjemalloc.so.2 |
| MALLOC_CONF | background_thread:true,dirty_decay_ms:5000,muzzy_decay_ms:0,narenas:2 |
| COMET_COMMIT_HASH / COMET_BUILD_DATE / COMET_BRANCH | build ARGs, set as env |

## Build ARGs
- TARGETPLATFORM (uv cache id), COMET_COMMIT_HASH, COMET_BUILD_DATE, COMET_BRANCH.

## Gotchas
- Build needs network for uv/rust stages; cache mount requires BuildKit.
- Python 3.13 base; Rust toolchain 1.97.1 in builder only.

# README (upstream, first 3000 chars, fetched 2026-11-27)
- Comet: Stremio add-on (torrent/debrid search). Docker setup documented at docs/beginner/01-get-started-docker.md (not fetched).
- Sample env file: .env-sample on main branch (not fetched).
