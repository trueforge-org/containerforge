


## TODO: replace with something of ours
FROM ghcr.io/by275/libtorrent:2-alpine3.22 AS libtorrent

FROM ghcr.io/trueforge-org/python:3.12.6

COPY --from=ghcr.io/astral-sh/uv:0.9.10@sha256:29bd45092ea8902c0bbb7f0a338f0494a382b1f4b18355df5be270ade679ff1d /uv /uvx /bin/

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# environment settings
ENV HOME="/config" \
  PYTHONIOENCODING=utf-8 \
  TMPDIR=/run/flexget-temp \
  UV_PROJECT_ENVIRONMENT=/config/venv \
  UV_COMPILE_BYTECODE=1 \
  UV_LINK_MODE=copy

RUN \
  echo "**** install packages ****" && \
  apk add -U --update --no-cache --virtual=build-dependencies \
    build-base \
    libffi-dev && \
  apk add  -U --update --no-cache \
    7zip \
    boost1.84-system \
    boost1.84-python3 \
    libstdc++ \
    nodejs && \
  echo "**** install flexget ****" && \
  mkdir -p /run/flexget-temp /data && \
  mkdir -p /app/flexget && \
  curl -o \
    /tmp/flexget.tar.gz -L \
    "https://github.com/Flexget/Flexget/archive/refs/tags/v${VERSION}.tar.gz" && \
  tar xf \
    /tmp/flexget.tar.gz -C \
    /app/flexget --strip-components=1 && \
  cd /app/flexget && \
  uv venv /config/venv && \
  uv run scripts/bundle_webui.py && \
  uv sync --frozen --no-dev --no-cache --group=all && \
  uv pip install pip && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /tmp/* \
    $HOME/.cache

# add local files
USER apps
COPY . /

COPY --from=libtorrent /libtorrent-build/usr/lib/libtorrent-rasterbar.* /usr/lib/
COPY --from=libtorrent /libtorrent-build/usr/lib/python3.12 /config/venv/lib/python3.12
COPY ./root /




# ports and volumes
EXPOSE 5050
VOLUME /config
