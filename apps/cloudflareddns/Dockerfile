

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:14fdd75a2018ad4e7fafcc60a29d4f389657f7faedbb277f8a91de858c6113f2
ARG TARGETARCH
ARG VENDOR
ARG VERSION

USER root
WORKDIR /app

USER apps:apps
COPY --from=ghcr.io/hotio/cloudflareddns:latest@sha256:6c258aff1991d8c7740856ec9a93722aa28852a93dbc3c2bf73e423b43b48d73 /app/cloudflare-ddns.sh /app/cloudflare-ddns.sh

COPY . /

WORKDIR /config
