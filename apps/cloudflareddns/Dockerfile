

FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:e855efee08935623aad3a45e3e554e52216b53d07105a9b3beb585ea1e78352c
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
COPY --from=ghcr.io/hotio/cloudflareddns:latest@sha256:2d5a3bb0862d4eea7a764691d464895e17d92b8795b14baa9469372fd54f2dd4 /app/cloudflare-ddns.sh /app/cloudflare-ddns.sh

# Fix shebang since container does not use s6-overlay
RUN sed -i 's|#!/command/with-contenv bash|#!/usr/bin/env bash|g' /app/cloudflare-ddns.sh

COPY --chmod=0755 . /

WORKDIR /config
