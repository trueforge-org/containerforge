

FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:2b0e3e5b096604f1f054edb5746abb22e6180ac4ae923d4f797ab697d4401eb0
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
