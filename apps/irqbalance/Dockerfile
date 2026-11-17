

FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:5b73e70bff124668c9432d50ac6bcdfb961c11e82debe5004aa68895feab0238
ARG VERSION

USER root
COPY --chmod=0755 . /

RUN apt-get update && \
    apt-get install -y --no-install-recommends irqbalance && \
    rm -rf /var/lib/apt/lists/* /tmp/*

ENTRYPOINT ["/usr/sbin/irqbalance", "--foreground"]
