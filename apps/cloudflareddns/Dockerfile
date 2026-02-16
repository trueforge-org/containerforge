

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:5d05227fca161b90936494534d014201795165beb84d5f1aced98565f7c6655e
ARG TARGETARCH
ARG VENDOR
ARG VERSION

USER root
WORKDIR /app

# Install dig
RUN apt-get update \
    && apt-get install -y --no-install-recommends dnsutils \
    && rm -rf /var/lib/apt/lists/*

USER apps:apps
COPY --from=ghcr.io/hotio/cloudflareddns:latest@sha256:195c3d07afc76e6db7119bd902f0565342976b5f6537461a97e09229dde14a5b /app/cloudflare-ddns.sh /app/cloudflare-ddns.sh

# Fix shebang since container does not use s6-overlay
RUN sed -i 's|#!/command/with-contenv bash|#!/usr/bin/env bash|g' /app/cloudflare-ddns.sh

COPY . /

WORKDIR /config
