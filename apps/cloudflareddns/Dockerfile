

FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:24efb13c405c262ba2d501640e0a70e0454439ed722125055b11814ff49323db
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
COPY --from=ghcr.io/hotio/cloudflareddns:latest@sha256:197bfbd90807aa987f374c94279abb78097487a99442f725133dd357b9e2748e /app/cloudflare-ddns.sh /app/cloudflare-ddns.sh

# Fix shebang since container does not use s6-overlay
RUN sed -i 's|#!/command/with-contenv bash|#!/usr/bin/env bash|g' /app/cloudflare-ddns.sh

COPY --chmod=0755 . /

WORKDIR /config
