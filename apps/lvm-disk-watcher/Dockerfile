FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:cab29d37a3d5e2d93201d98363c0169152d9d7147518121900f5587da719df62

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
