

FROM ghcr.io/trueforge-org/python:3.15.0@sha256:cc77b726944ed790a1b47a8dfc52868391e2558d09193e1524f5ca74e0ccad5d
ARG VERSION
# renovate: datasource=pypi depName=esphome-device-builder
ARG ESPHOME_DEVICE_BUILDER_VERSION=1.26.0

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
        "esphome-device-builder==${ESPHOME_DEVICE_BUILDER_VERSION}"; \
    rm -rf /tmp/*

# Copy application code

USER apps
COPY --chmod=0755 . /
WORKDIR /config

CMD ["dashboard", "/config"]
