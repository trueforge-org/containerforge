

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:f4f97014103ddd97cb710e71b9c6df79d4537dd0ce53d56c175fadd4c28139eb
ARG TARGETARCH
ARG VENDOR
ARG VERSION

USER root
WORKDIR /app

USER apps:apps
COPY --from=ghcr.io/hotio/cloudflareddns:latest@sha256:a20961733e5756bb1fc559db5ba8d17f690d9026abc322c2681de4b74a8d41ef /app/cloudflare-ddns.sh /app/cloudflare-ddns.sh

COPY . /

WORKDIR /config
