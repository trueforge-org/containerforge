

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:36c48bc0fd413c8ef2ae9761b1decc96fa8295f44407a9b7280bd137c2109355
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

COPY . /

USER apps
COPY container-test.yaml /container-test.yaml
WORKDIR /config
