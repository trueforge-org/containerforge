

FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:5491a2f46a8408f4085d5b92ff59358bafd56e7f26058b30347bfdefa568ed8a
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
COPY --from=ghcr.io/hotio/cloudflareddns:latest@sha256:0dd97ed9d5eb8feb2dee27fb8c6151ea9e950f3afea956e694aa3e601e266d67 /app/cloudflare-ddns.sh /app/cloudflare-ddns.sh

# Fix shebang since container does not use s6-overlay
RUN sed -i 's|#!/command/with-contenv bash|#!/usr/bin/env bash|g' /app/cloudflare-ddns.sh

COPY --chmod=0755 . /

WORKDIR /config
