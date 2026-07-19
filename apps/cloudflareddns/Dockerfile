

FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:c17d482490e086584ab0668a69494d9e9acd5cf95e1bcf500143dc63c1963ba3
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
COPY --from=ghcr.io/hotio/cloudflareddns:latest@sha256:1ac0599b099f1306304bccb551d10b0d6c6f0bf4a7e45e46e784ad287cbff8ea /app/cloudflare-ddns.sh /app/cloudflare-ddns.sh

# Fix shebang since container does not use s6-overlay
RUN sed -i 's|#!/command/with-contenv bash|#!/usr/bin/env bash|g' /app/cloudflare-ddns.sh

COPY --chmod=0755 . /

WORKDIR /config
