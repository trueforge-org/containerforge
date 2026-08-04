

FROM ghcr.io/trueforge-org/python:3.14.6@sha256:1470b61147b07e36671bd6765c908f0d582088e2cb946c8029836fe06d20c84c
ARG VERSION

ENV \
    HOME="/config" \
    PLATFORMIO_CORE_DIR=/tmp/pio \
    ESPHOME_BUILD_PATH=/tmp/build \
    ESPHOME_DATA_DIR=/tmp/data

USER root
WORKDIR /app

# Install dependencies and Python packages
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        git \
        iputils-ping \
        libcairo2 \
        file \
        openssh-client \
        patch \
        && rm -rf /var/lib/apt/lists/*; \
    pip install uv; \
    uv pip install \
        setuptools \
        "esphome[displays]==${VERSION}" \
        "esphome-device-builder==1.6.8"; \
    rm -rf /tmp/*

# Copy application code

USER apps
COPY --chmod=0755 . /
WORKDIR /config

CMD ["dashboard", "/config"]
