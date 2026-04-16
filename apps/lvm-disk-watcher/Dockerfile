FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:b91efc25164fbe723a41eca66f239d8f6c008fd7d10ceda9d5ba0975104d0432

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
