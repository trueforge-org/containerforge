FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION

USER root

# Prebuilt cp39-abi3 wheels exist for amd64 and arm64, so no compiler is needed.
RUN set -eux; \
    /app/venv/bin/pip install --no-cache-dir "chromadb==${VERSION}"; \
    test "$(/app/venv/bin/python -c 'import importlib.metadata as m; print(m.version("chromadb"))')" = "${VERSION}"; \
    chown -R root:root /app/venv; \
    chmod -R a+rX /app/venv

ENV IS_PERSISTENT=1 \
    PERSIST_DIRECTORY=/config/chroma \
    CHROMA_HOST_ADDR=0.0.0.0 \
    CHROMA_HOST_PORT=8000 \
    CHROMA_WORKERS=1 \
    CHROMA_TIMEOUT_KEEP_ALIVE=30

USER apps
COPY --chmod=0755 . /

EXPOSE 8000
VOLUME /config
WORKDIR /config

CMD ["/start.sh"]
