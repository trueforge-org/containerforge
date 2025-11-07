# syntax=docker/dockerfile:1

FROM ghcr.io/trueforge-org/python:3.13.7@sha256:eb8c395317bd3e807501ef61f4d16a9582b11db2e28c46e74d1dd6c9762002a4
ARG VERSION

ENV \
    HOME="/config" \
    PLATFORMIO_CORE_DIR=/cache/pio \
    ESPHOME_BUILD_PATH=/cache/build \
    ESPHOME_DATA_DIR=/cache/data

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
        "esphome[displays]==${VERSION}"; \
    rm -rf /tmp/*

# Copy application code
COPY . /

USER nobody:nogroup
WORKDIR /config

CMD ["dashboard", "/config"]
