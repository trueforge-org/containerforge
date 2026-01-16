FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:b1fa023ff8e056bfe31075b3cfec6a5de5572e1eee730d1365d3893243d7163c

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
