

FROM ghcr.io/trueforge-org/python:3.14.4@sha256:622c7c1053c59c31674e5c31b88b1a7cfa61b0f5fbabebb38dd9a4ab5e2f6ee1
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

USER apps
COPY --chmod=0755 . /
WORKDIR /config

CMD ["dashboard", "/config"]
