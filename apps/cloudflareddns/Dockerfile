

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:5fa3c2cf644e1cf005b5ee0feac4b0d0041f65850fb1991bef3926c45a9a371c
ARG TARGETARCH
ARG VENDOR
ARG VERSION

USER root
WORKDIR /app

# Install dig
RUN apt-get update \
    && apt-get install -y --no-install-recommends dnsutils \
    && rm -rf /var/lib/apt/lists/*

USER apps
COPY --from=ghcr.io/hotio/cloudflareddns:latest@sha256:85e8b753ec9769db68fbda8dbcd2869f3ed0e5e00a76a6a2fcc9bac43b6dc2c1 /app/cloudflare-ddns.sh /app/cloudflare-ddns.sh

# Fix shebang since container does not use s6-overlay
RUN sed -i 's|#!/command/with-contenv bash|#!/usr/bin/env bash|g' /app/cloudflare-ddns.sh

COPY --chmod=0755 . /

WORKDIR /config
