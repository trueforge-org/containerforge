FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:128e24cac8026983dcd46413896d467cc1ffae9d933164f758866e7519eae606

ARG TARGETPLATFORM
ARG VERSION

USER root

# Copy files with ownership
COPY --chown=568:568 . /

# Install LVM and dependencies, make script executable
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        lvm2 \
        dmsetup && \
    chmod +x /app/watch_lvm.sh && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

ENTRYPOINT ["/bin/bash", "/scripts/watch_lvm.sh"]

USER apps:apps
