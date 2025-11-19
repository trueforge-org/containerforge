

FROM ghcr.io/trueforge-org/python:3.13.7@sha256:6119b5ecab933bfd4ceb9c7e56b8c93379b830d6a5af0aa9cb7b014e1078be8f
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

USER apps:apps
WORKDIR /config

CMD ["dashboard", "/config"]
