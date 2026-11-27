# GitHub chroma-core/chroma Dockerfile (pinned commit 11f3c74)

## Source URL(s) + date
- https://raw.githubusercontent.com/chroma-core/chroma/11f3c7435e71024aa0a2b53710a28d3289d922d1/Dockerfile (fetched 2026-11-27)

## Build stage (`AS builder`, python:3.11-slim-bookworm)
- ARG REBUILD_HNSWLIB; ARG PROTOC_VERSION=31.1
- apt: build-essential gcc g++ cmake autoconf python3-dev unzip curl make
- rustup (stable toolchain) via curl sh.rustup.rs; PATH adds /root/.cargo/bin
- protoc zip per arch (x86_64, aarch64 only; other arch fails) from protobuf GitHub release v${PROTOC_VERSION}
- pip install maturin cffi patchelf; pip install -r requirements.txt into /install; optional chroma-hnswlib rebuild
- pip install grpcio==1.58.0 grpcio-tools==1.58.0
- COPY source to /chroma; `make -C idl proto_python`; `python3 -m maturin build`; pip install chromadb from target/wheels into /install

## Final stage (python:3.11-slim-bookworm)
- `mkdir /chroma`; WORKDIR /chroma
- COPY bin/docker_entrypoint.sh to /docker_entrypoint.sh; apt install curl; chmod +x
- COPY --from=builder /install to /usr/local; /chroma
- ENV CHROMA_HOST_ADDR=0.0.0.0, CHROMA_HOST_PORT=8000, CHROMA_WORKERS=1, CHROMA_LOG_CONFIG=chromadb/log_config.yml, CHROMA_TIMEOUT_KEEP_ALIVE=30
- `EXPOSE 8000`
- `ENTRYPOINT ["/docker_entrypoint.sh"]`
- `CMD ["--workers ${CHROMA_WORKERS} --host ${CHROMA_HOST_ADDR} --port ${CHROMA_HOST_PORT} --proxy-headers --reload --log-config ${CHROMA_LOG_CONFIG} --timeout-keep-alive ${CHROMA_TIMEOUT_KEEP_ALIVE}"]` (single string, not expanded by exec form)
- No USER line (root).

## Gotchas
- CMD is one quoted string in exec form, so `${VAR}` expansion relies on the entrypoint eval (docker_entrypoint uses `eval echo`).
- `--reload` is in default CMD (dev flag).
- Build needs Rust and protoc; runtime needs only the Python install.
