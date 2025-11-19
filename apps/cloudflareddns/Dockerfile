

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:4199c1486b3e46e0d990afe382130d196c0aae8b76948bc73997b46e44b0caba
ARG TARGETARCH
ARG VENDOR
ARG VERSION

USER root
WORKDIR /app

USER apps:apps
COPY --from=ghcr.io/hotio/cloudflareddns:latest@sha256:b64687779bbe0dcd41f9854129ce8fa9d6c5f009e1992a79bed97c85fe253eaf /app/cloudflare-ddns.sh /app/cloudflare-ddns.sh

COPY . /

WORKDIR /config
