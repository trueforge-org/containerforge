

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:481e4b09787d863f5248d809137b760be46248238ad6a122116ce122e03e1e3f
ARG VERSION

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends irqbalance && \
    rm -rf /var/lib/apt/lists/* /tmp/*

ENTRYPOINT ["/usr/sbin/irqbalance", "--foreground"]
