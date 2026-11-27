FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d AS build

ARG VERSION
ARG TARGETARCH
# sha256 of the v${VERSION} source tarball, fetched 2026-11-27 (re-check at build)
ARG COMET_SHA256=480258af7348ac3af29d8c5bba49bf04cbf1f89e7ba2db3a4dbab24299768c38
ARG UV_VERSION=0.11.32
USER root

# UNVERIFIED: gcc and libc6-dev are needed only if a dependency compiles on arm64. Rust is not installed.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gcc \
        libc6-dev \
        make && \
    rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir "uv==${UV_VERSION}"

RUN curl -fsSL -o /tmp/comet.tar.gz "https://github.com/g0ldyy/comet/archive/refs/tags/v${VERSION}.tar.gz" && \
    echo "${COMET_SHA256}  /tmp/comet.tar.gz" | sha256sum -c - && \
    mkdir -p /tmp/src && \
    tar xzf /tmp/comet.tar.gz -C /tmp/src --strip-components=1

# UNVERIFIED: uv.lock was not read, so per-arch wheel availability is unknown.
RUN UV_CACHE_DIR=/tmp/uv-cache \
    UV_PYTHON_DOWNLOADS=never \
    UV_PROJECT_ENVIRONMENT=/app/comet/.venv \
    uv sync --frozen --no-install-project --project /tmp/src && \
    mkdir -p /app/comet /usr/share/licenses/comet && \
    cp -r /tmp/src/comet /app/comet/comet && \
    cp /tmp/src/LICENSE /usr/share/licenses/comet/LICENSE && \
    rm -rf /tmp/* /root/.cache

FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION
USER root

COPY --from=build /app/comet /app/comet
COPY --from=build /usr/share/licenses/comet /usr/share/licenses/comet

# Data paths in comet are relative to the working directory (/app/comet), so data/ points at the persistent /config.
# UNVERIFIED: jemalloc (LD_PRELOAD in upstream) is not added; the python base may not ship libjemalloc.
RUN chown -R root:root /app && \
    chmod -R 755 /app && \
    ln -s /config/data /app/comet/data

ENV \
  PYTHONDONTWRITEBYTECODE=1 \
  PYTHONUNBUFFERED=1 \
  PYTHONMALLOC=malloc \
  MALLOC_CONF=background_thread:true,dirty_decay_ms:5000,muzzy_decay_ms:0,narenas:2 \
  TZ=UTC \
  PATH=/app/comet/.venv/bin:$PATH \
  HOME=/config

USER apps
COPY --chmod=0755 . /

EXPOSE 8000

VOLUME /config

WORKDIR /app/comet
