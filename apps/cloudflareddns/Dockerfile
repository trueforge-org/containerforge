

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:d7637b3330e77450c56e9682790fd79f8c63124dff1593086c05d74d0179a39f
ARG TARGETARCH
ARG VENDOR
ARG VERSION

USER root
WORKDIR /app

USER apps:apps
COPY --from=ghcr.io/hotio/cloudflareddns:latest@sha256:b64687779bbe0dcd41f9854129ce8fa9d6c5f009e1992a79bed97c85fe253eaf /app/cloudflare-ddns.sh /app/cloudflare-ddns.sh

COPY . /

WORKDIR /config
