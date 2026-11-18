

FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:1e4ce94f2d255834fe7557fd2de50f2c021834c8eff14e43b84b70a768cd8348
ARG VERSION

USER root
COPY --chmod=0755 . /

RUN apt-get update && \
    apt-get install -y --no-install-recommends irqbalance && \
    rm -rf /var/lib/apt/lists/* /tmp/*

ENTRYPOINT ["/usr/sbin/irqbalance", "--foreground"]
