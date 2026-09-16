FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:fe30ffe7e0841a2e19f3a508d9ae62b594feada6829d9b78d21cd534a8e8ac8b

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

USER apps
COPY --chmod=0755 . /

# Copy files with correct permissions
COPY --chmod=775 . /
