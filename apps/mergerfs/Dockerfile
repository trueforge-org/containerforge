

FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:9ec5de91a1fb401ba4739f36a6b8dfaf70fd8dc75735fdf608e23392f9be29ba
ARG TARGETARCH
ARG VENDOR
ARG VERSION

USER root
WORKDIR /app

RUN apt-get update && \
    apt-get install -y fuse && \
    rm -rf /var/lib/apt/lists/*

ADD "https://github.com/trapexit/mergerfs/releases/download/${VERSION}/mergerfs-${VERSION}-static-linux_${TARGETARCH}.tar.gz" "/tmp"
RUN tar xzf "/tmp/mergerfs-${VERSION}-static-linux_${TARGETARCH}.tar.gz" -C "/" && \
    rm -rf "/tmp/mergerfs-${VERSION}-static-linux_${TARGETARCH}.tar.gz"


USER apps
COPY --chmod=0755 . /
WORKDIR /config
