FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:cdc35c1e179c9ebb98d18ad2f3c3b5ff340fbda5e75ccbd4f022ef7da5885760

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
