

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:7c408e37ca12764efcd1e7d413e7db4ce6dc4640b338d184b0cfc416f2cf2d64
ARG VERSION

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends irqbalance && \
    rm -rf /var/lib/apt/lists/* /tmp/*

ENTRYPOINT ["/usr/sbin/irqbalance", "--foreground"]
