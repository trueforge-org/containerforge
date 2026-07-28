

FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:2b0e3e5b096604f1f054edb5746abb22e6180ac4ae923d4f797ab697d4401eb0
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
COPY --from=ghcr.io/hotio/cloudflareddns:latest@sha256:918943aaadc2f38633394d4d3dd084cb99c9aba16f82a8605bb71d97edb4c145 /app/cloudflare-ddns.sh /app/cloudflare-ddns.sh

# Fix shebang since container does not use s6-overlay
RUN sed -i 's|#!/command/with-contenv bash|#!/usr/bin/env bash|g' /app/cloudflare-ddns.sh

COPY --chmod=0755 . /

WORKDIR /config
