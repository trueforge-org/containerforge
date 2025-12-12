

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:f4f97014103ddd97cb710e71b9c6df79d4537dd0ce53d56c175fadd4c28139eb
ARG TARGETARCH
ARG VENDOR
ARG VERSION

USER root
WORKDIR /app

USER apps:apps
COPY --from=ghcr.io/hotio/cloudflareddns:latest@sha256:6c258aff1991d8c7740856ec9a93722aa28852a93dbc3c2bf73e423b43b48d73 /app/cloudflare-ddns.sh /app/cloudflare-ddns.sh

COPY . /

WORKDIR /config
