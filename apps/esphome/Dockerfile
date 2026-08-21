

FROM ghcr.io/trueforge-org/python:3.14.7@sha256:05a7bc16dd8486cbe36714903407947136771e66de31cf93d562200e8a665def
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
