

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:d7637b3330e77450c56e9682790fd79f8c63124dff1593086c05d74d0179a39f
ARG VERSION

USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends irqbalance && \
    rm -rf /var/lib/apt/lists/* /tmp/*

ENTRYPOINT ["/usr/sbin/irqbalance", "--foreground"]
