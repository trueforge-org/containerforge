

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:e0f946b03dc12bbfa4f72629bd61690502df47c59b4105bc37fe346dc5d489b8
ARG VERSION

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends irqbalance && \
    rm -rf /var/lib/apt/lists/* /tmp/*

ENTRYPOINT ["/usr/sbin/irqbalance", "--foreground"]
