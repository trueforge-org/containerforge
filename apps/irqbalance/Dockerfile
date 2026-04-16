

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:b91efc25164fbe723a41eca66f239d8f6c008fd7d10ceda9d5ba0975104d0432
ARG VERSION

USER root
COPY --chmod=0755 . /

RUN apt-get update && \
    apt-get install -y --no-install-recommends irqbalance && \
    rm -rf /var/lib/apt/lists/* /tmp/*

ENTRYPOINT ["/usr/sbin/irqbalance", "--foreground"]
