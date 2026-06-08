

FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:c21fcd861c5eccd1dec9c7b9a88647fc3a22585c3d7cf77ba48129844e7a584b
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
COPY --from=ghcr.io/hotio/cloudflareddns:latest@sha256:4f28f3f0aedf2948809cfc246f83ab6297c9b6e15eac2638ebff9579dadfcd7f /app/cloudflare-ddns.sh /app/cloudflare-ddns.sh

# Fix shebang since container does not use s6-overlay
RUN sed -i 's|#!/command/with-contenv bash|#!/usr/bin/env bash|g' /app/cloudflare-ddns.sh

COPY --chmod=0755 . /

WORKDIR /config
