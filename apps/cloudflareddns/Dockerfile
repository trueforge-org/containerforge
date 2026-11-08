

FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:a3ec289cfc10acc23a20cfb4fe5033c944ce3073dc4a53157c093ffb52f983b1
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
COPY --from=ghcr.io/hotio/cloudflareddns:latest@sha256:e28589cacf7d54d8d6527c2743ee0a24352e3968a40fb74ef7e5ede1a62e6dbd /app/cloudflare-ddns.sh /app/cloudflare-ddns.sh

# Fix shebang since container does not use s6-overlay
RUN sed -i 's|#!/command/with-contenv bash|#!/usr/bin/env bash|g' /app/cloudflare-ddns.sh

COPY --chmod=0755 . /

WORKDIR /config
