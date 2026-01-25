

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:431129004c8b82702e6a1c82ffc20d64c770179547c8d77deb7133c314a6d3b8
ARG VERSION

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends irqbalance && \
    rm -rf /var/lib/apt/lists/* /tmp/*

ENTRYPOINT ["/usr/sbin/irqbalance", "--foreground"]
