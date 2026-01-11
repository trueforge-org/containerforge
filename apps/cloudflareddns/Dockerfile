

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:f4f97014103ddd97cb710e71b9c6df79d4537dd0ce53d56c175fadd4c28139eb
ARG TARGETARCH
ARG VENDOR
ARG VERSION

USER root
WORKDIR /app

USER apps:apps
COPY --from=ghcr.io/hotio/cloudflareddns:latest@sha256:24eac87c0dd061e23b80f0d9e71aa9d8a1311897091c494e6b351ae7d11071ce /app/cloudflare-ddns.sh /app/cloudflare-ddns.sh

COPY . /

WORKDIR /config
