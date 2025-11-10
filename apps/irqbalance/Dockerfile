

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:91d978bcece60398d9a21a2f331801d9004f5651a323f8f25ed2fa70b5d8eacd
ARG VERSION

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends irqbalance && \
    rm -rf /var/lib/apt/lists/* /tmp/*

ENTRYPOINT ["/usr/sbin/irqbalance", "--foreground"]
