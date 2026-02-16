

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:5d05227fca161b90936494534d014201795165beb84d5f1aced98565f7c6655e
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
