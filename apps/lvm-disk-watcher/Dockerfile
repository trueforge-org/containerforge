FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:8b0b1f042b2fd6d7a2a8ad73e0b4470404cabfee1d209ae04fe6fcd2cc761152

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

ENTRYPOINT ["/bin/bash", "/app/watch_lvm.sh"]

USER apps
COPY --chmod=0755 . /
