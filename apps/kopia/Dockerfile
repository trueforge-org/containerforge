

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:6064d5af956ed39456b8c643d6434d9d5331f4d77c08230a413f6a1b253a1408
ARG TARGETARCH
ARG VERSION

# Normalize architecture names
ARG TARGETARCH=${TARGETARCH/amd64/x64}

ENV \
    KOPIA_CHECK_FOR_UPDATES=false \
    KOPIA_CONFIG_PATH=/config/repository.config \
    KOPIA_CACHE_DIRECTORY=/config/cache \
    KOPIA_LOG_DIR=/config/logs \
    KOPIA_PERSIST_CREDENTIALS_ON_CONNECT=false \
    KOPIA_WEB_ENABLED=true \
    KOPIA_WEB_PORT=51515

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends curl tar ca-certificates && \
    curl -fsSL "https://github.com/kopia/kopia/releases/download/${VERSION}/kopia-${VERSION#*v}-linux-${TARGETARCH}.tar.gz" \
        | tar xzf - -C /usr/local/bin --strip-components 1 && \
    rm -rf /var/lib/apt/lists/* /tmp/*

COPY . /

USER apps
WORKDIR /config
