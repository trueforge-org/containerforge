

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:f8e39d9e103184c2df3c555390f2a5cd02bbc0f61a70199c718bb18bce830f4b
ARG TARGETARCH
ARG VENDOR
ARG VERSION

USER root
WORKDIR /app

RUN apt-get update && \
    apt-get install -y fuse && \
    rm -rf /var/lib/apt/lists/*

ADD "https://github.com/trapexit/mergerfs/releases/download/${VERSION}/mergerfs-${VERSION}-static-linux_amd64.tar.gz" "/tmp"
RUN tar xzf "/tmp/mergerfs-${VERSION}-static-linux_amd64.tar.gz" -C "/" && \
    rm -rf "/tmp/mergerfs-${VERSION}-static-linux_amd64.tar.gz"

COPY . /

USER root:root
WORKDIR /config
