FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION
ARG SOURCE_REF
USER root

# UNVERIFIED: python 3.15 wheels for curl_cffi, lxml and others; add build packages only if a wheel is missing.
ENV \
  PIP_NO_CACHE_DIR=1 \
  PIP_CACHE_DIR=/tmp/pip-cache \
  __SEARXNG_VERSION=${VERSION} \
  __SEARXNG_CONFIG_PATH=/config \
  __SEARXNG_DATA_PATH=/tmp/searxng

RUN echo "*** Fetching SearXNG ${VERSION} (${SOURCE_REF}) ***" && \
  mkdir -p /tmp/searxng && \
  curl -fL \
    "https://github.com/searxng/searxng/archive/${SOURCE_REF}.tar.gz" | \
  tar xz -C /tmp/searxng --strip-components=1

# UNVERIFIED: requirements-server.txt (granian) contents were not fetched; upstream installs it with uv.
RUN echo "*** Installing SearXNG dependencies ***" && \
  /app/venv/bin/pip install --no-cache-dir \
    -r /tmp/searxng/requirements.txt \
    -r /tmp/searxng/requirements-server.txt

RUN echo "*** Installing SearXNG app ***" && \
  mkdir -p /app/searxng /usr/share/licenses/searxng && \
  cp -r /tmp/searxng/searx /app/searxng/searx && \
  cp /tmp/searxng/container/settings.template.yml /app/searxng/settings.template.yml && \
  cp /tmp/searxng/LICENSE /usr/share/licenses/searxng/LICENSE && \
  echo "*** Cleaning Up ***" && \
  rm -rf /tmp/searxng /tmp/pip-cache /tmp/* && \
  chown -R root:root /app/searxng && chmod -R 755 /app/searxng

ENV \
  GRANIAN_PROCESS_NAME=searxng \
  GRANIAN_INTERFACE=wsgi \
  GRANIAN_HOST=0.0.0.0 \
  GRANIAN_PORT=8080 \
  GRANIAN_WEBSOCKETS=false \
  GRANIAN_BLOCKING_THREADS=4 \
  GRANIAN_WORKERS_KILL_TIMEOUT=30s \
  GRANIAN_BLOCKING_THREADS_IDLE_TIMEOUT=5m

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config

WORKDIR /app/searxng
