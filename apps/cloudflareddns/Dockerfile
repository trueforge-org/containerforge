

FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:5cb91be3e738ebbd91b616dc8ec0dd21d25980038f39d6b941f30a0b106d1ecf
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
COPY --from=ghcr.io/hotio/cloudflareddns:latest@sha256:7f6d24cb5b8adace152642581cc6edd2b1f78482d303b63bffb55078a254f30b /app/cloudflare-ddns.sh /app/cloudflare-ddns.sh

# Fix shebang since container does not use s6-overlay
RUN sed -i 's|#!/command/with-contenv bash|#!/usr/bin/env bash|g' /app/cloudflare-ddns.sh

COPY --chmod=0755 . /

WORKDIR /config
