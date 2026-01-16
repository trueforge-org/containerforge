

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:481e4b09787d863f5248d809137b760be46248238ad6a122116ce122e03e1e3f
ARG TARGETARCH
ARG VENDOR
ARG VERSION

USER root
WORKDIR /app

USER apps:apps
COPY --from=ghcr.io/hotio/cloudflareddns:latest@sha256:46ce9b960c0a2610ce305724b726a8a73cf336944e3d598f7a82abaf6bc2ca68 /app/cloudflare-ddns.sh /app/cloudflare-ddns.sh

COPY . /

WORKDIR /config
