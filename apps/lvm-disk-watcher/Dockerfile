FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:1685c0f458568fddff62e0fe0f0804de9d13469bd9fc967bc8c7bde606166969

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

USER apps
COPY --chmod=0755 . /
