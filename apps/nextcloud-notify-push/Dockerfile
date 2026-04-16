FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:c5a3b56e4d22600d2b618d602d487732516cc067cb21969798210c3b12304842

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
