

FROM ghcr.io/trueforge-org/python:3.13.12@sha256:3fa12464f1313ee6c634acc679d3b3fd4ef8c8412eb1ccf2e8720012ae514d91
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
COPY --chmod=0755 . /

USER apps
COPY --chmod=0755 container-test.yaml /container-test.yaml
WORKDIR /config

CMD ["dashboard", "/config"]
