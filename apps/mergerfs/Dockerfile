

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:7c408e37ca12764efcd1e7d413e7db4ce6dc4640b338d184b0cfc416f2cf2d64
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
