

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:5d05227fca161b90936494534d014201795165beb84d5f1aced98565f7c6655e
ARG VERSION

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends irqbalance && \
    rm -rf /var/lib/apt/lists/* /tmp/*

ENTRYPOINT ["/usr/sbin/irqbalance", "--foreground"]
