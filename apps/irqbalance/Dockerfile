

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:cc82810600df75ed627ea3453ff80a6fc5204ea48139834e41f0c74e685ef776
ARG VERSION

USER root
COPY --chmod=0755 . /

RUN apt-get update && \
    apt-get install -y --no-install-recommends irqbalance && \
    rm -rf /var/lib/apt/lists/* /tmp/*

ENTRYPOINT ["/usr/sbin/irqbalance", "--foreground"]
