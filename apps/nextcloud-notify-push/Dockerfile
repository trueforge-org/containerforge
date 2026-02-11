FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:3b826c0233182d7c31a9323121178b98976765b9ee03f9a96200ab0c70e2e1e2

USER root

# Install required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget && \
    rm -rf /var/lib/apt/lists/*

ARG VERSION
ARG TARGETARCH
ARG TARGETARCH=${TARGETARCH/arm64/aarch64}
ARG TARGETARCH=${TARGETARCH/amd64/x86_64}
ARG TRIPLET="unknown-linux-musl"

# Download notify_push binary
RUN set -eux; \
    wget -q -O /usr/local/bin/notify_push "https://github.com/nextcloud/notify_push/releases/download/v${VERSION}/notify_push-${TARGETARCH}-${TRIPLET}"; \
    chmod +x /usr/local/bin/notify_push;

USER apps:apps

# Copy files with correct permissions
COPY --chmod=775 . /
