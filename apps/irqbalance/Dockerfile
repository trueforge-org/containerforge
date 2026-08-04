

FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:e855efee08935623aad3a45e3e554e52216b53d07105a9b3beb585ea1e78352c
ARG VERSION

USER root
COPY --chmod=0755 . /

RUN apt-get update && \
    apt-get install -y --no-install-recommends irqbalance && \
    rm -rf /var/lib/apt/lists/* /tmp/*

ENTRYPOINT ["/usr/sbin/irqbalance", "--foreground"]
