FROM ghcr.io/trueforge-org/python:3.13.12

COPY --from=ghcr.io/astral-sh/uv:0.11.8@sha256:3b7b60a81d3c57ef471703e5c83fd4aaa33abcd403596fb22ab07db85ae91347 /uv /uvx /bin/

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# environment settings
ENV HOME="/config" \
  PYTHONIOENCODING=utf-8 \
  TMPDIR=/run/flexget-temp \
  UV_PROJECT_ENVIRONMENT=/app/venv \
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
    (curl -fL -o /tmp/flexget.tar.gz "https://github.com/Flexget/Flexget/archive/refs/tags/v${VERSION}.tar.gz" || curl -fL -o /tmp/flexget.tar.gz "https://github.com/Flexget/Flexget/archive/refs/tags/${VERSION}.tar.gz" || curl -fL -o /tmp/flexget.tar.gz "https://github.com/Flexget/Flexget/archive/refs/heads/main.tar.gz") && \
    tar xf \
        /tmp/flexget.tar.gz -C \
        /app/flexget --strip-components=1 && \
    cd /app/flexget && \
    uv venv /app/venv && \
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
COPY --chmod=0755 . /





# ports and volumes
EXPOSE 5050
VOLUME /config

WORKDIR /config
