FROM ghcr.io/by275/libtorrent:2-alpine3.22@sha256:647bd0036eb75df110dc0277118d2941babffe0e7b53b921a363fa573ea43d83 AS libtorrent

FROM ghcr.io/trueforge-org/python:3.13.7@sha256:436649ee533b748645c1e3ad8e4a1fc3fd2d9d4f0b1cc937bf742a5c3a7f32e5

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
    apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential \
        libffi-dev \
        p7zip-full \
        libboost-system-dev \
        libboost-python-dev \
        libstdc++6 \
        nodejs && \
    echo "**** install flexget ****" && \
    mkdir -p /run/flexget-temp /data && \
    mkdir -p /app/flexget && \
    $SELECTION_PLACEHOLDER$ \
    tar xf \
        /tmp/flexget.tar.gz -C \
        /app/flexget --strip-components=1 && \
    cd /app/flexget && \
    uv venv /config/venv && \
    uv run scripts/bundle_webui.py && \
    uv sync --frozen --no-dev --no-cache --group=all && \
    uv pip install pip && \
    echo "**** cleanup ****" && \
    apt-get remove --purge -y build-essential libffi-dev && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf \
        /tmp/* \
        $HOME/.cache \
        /var/lib/apt/lists/*


# add local files
USER apps
COPY . /

COPY --from=libtorrent /libtorrent-build/usr/lib/libtorrent-rasterbar.* /usr/lib/
COPY --from=libtorrent /libtorrent-build/usr/lib/python3.12 /config/venv/lib/python3.12
COPY ./root /




# ports and volumes
EXPOSE 5050
VOLUME /config

WORKDIR /config
