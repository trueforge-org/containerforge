

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:accb07943840b6a8b3a09886789c72f0121189e7d78e6f954a5c81194318e6c2
ARG TARGETARCH
ARG VENDOR
ARG VERSION

USER root
WORKDIR /app

USER apps:apps
COPY --from=ghcr.io/hotio/cloudflareddns:latest@sha256:b64687779bbe0dcd41f9854129ce8fa9d6c5f009e1992a79bed97c85fe253eaf /app/cloudflare-ddns.sh /app/cloudflare-ddns.sh

COPY . /

WORKDIR /config
