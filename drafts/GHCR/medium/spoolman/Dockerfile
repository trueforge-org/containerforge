
# stay on python 3.14 until spoolman supports 3.15 (requires-python >=3.10,<3.15, same pin as apps/beets)
FROM ghcr.io/trueforge-org/python:3.14.8@sha256:f099b700b824b7760cb846418f84a2c14c2f04992320506ab3ca5b79d3ac1232

# set version label
ARG VERSION
# release asset digest for spoolman.zip at VERSION (renovate does not update it)
ARG SPOOLMAN_SHA256
USER root

RUN \
  echo "**** download and verify spoolman ****" && \
  curl -fL -o /tmp/spoolman.zip \
    "https://github.com/Donkie/Spoolman/releases/download/v${VERSION}/spoolman.zip" && \
  echo "${SPOOLMAN_SHA256}  /tmp/spoolman.zip" | sha256sum -c - && \
  echo "**** extract (UNVERIFIED: zip holds the package, pyproject.toml, uv.lock and built client dirs, flat at the root) ****" && \
  mkdir -p /app/spoolman && \
  python3 -m zipfile -e /tmp/spoolman.zip /app/spoolman && \
  rm -f /tmp/spoolman.zip && \
  echo "**** install locked python dependencies into /app/venv ****" && \
  python3 -m venv /tmp/uv-tool && \
  /tmp/uv-tool/bin/pip install --no-cache-dir uv && \
  python3 -m venv /app/venv && \
  cd /app/spoolman && \
  UV_CACHE_DIR=/tmp/uv-cache UV_LINK_MODE=copy UV_NO_DEV=1 UV_PYTHON_DOWNLOADS=0 UV_PROJECT_ENVIRONMENT=/app/venv \
    /tmp/uv-tool/bin/uv sync --locked --no-install-project && \
  UV_CACHE_DIR=/tmp/uv-cache UV_LINK_MODE=copy UV_NO_DEV=1 UV_PYTHON_DOWNLOADS=0 UV_PROJECT_ENVIRONMENT=/app/venv \
    /tmp/uv-tool/bin/uv sync --locked && \
  echo "**** license (UNVERIFIED: LICENSE is in the zip) ****" && \
  mkdir -p /usr/share/licenses/spoolman && \
  if [ -f /app/spoolman/LICENSE ]; then cp /app/spoolman/LICENSE /usr/share/licenses/spoolman/; fi && \
  echo "**** cleanup ****" && \
  rm -rf /tmp/* $HOME/.cache

ENV PATH="/app/venv/bin:${PATH}" \
    SPOOLMAN_HOST=0.0.0.0 \
    SPOOLMAN_PORT=8000 \
    HOME=/config

# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 8000
VOLUME /config

WORKDIR /app/spoolman
