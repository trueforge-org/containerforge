

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:cc82810600df75ed627ea3453ff80a6fc5204ea48139834e41f0c74e685ef776
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
COPY --from=ghcr.io/hotio/cloudflareddns:latest@sha256:8ffaad9cf7886c0f24f0af49f62657beb7b790fdf585567f0fa52bd85615e708 /app/cloudflare-ddns.sh /app/cloudflare-ddns.sh

# Fix shebang since container does not use s6-overlay
RUN sed -i 's|#!/command/with-contenv bash|#!/usr/bin/env bash|g' /app/cloudflare-ddns.sh

COPY --chmod=0755 . /

WORKDIR /config
