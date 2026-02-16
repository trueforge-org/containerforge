

FROM ghcr.io/trueforge-org/python:3.14.3@sha256:ce429d498a8b592f7495c3cd2ac98d31c56d4ffaf00cacbb49e418494e25c626
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
