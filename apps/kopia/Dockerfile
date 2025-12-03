

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:f8e39d9e103184c2df3c555390f2a5cd02bbc0f61a70199c718bb18bce830f4b
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

USER apps:apps
WORKDIR /config
