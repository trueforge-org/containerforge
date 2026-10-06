

FROM ghcr.io/trueforge-org/python:3.14.8@sha256:c298a5e065ea46d0280a6f0e4b696c549d169a280e63ee6b49791865753112ca
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
