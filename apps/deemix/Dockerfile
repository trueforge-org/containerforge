
FROM ghcr.io/trueforge-org/node:24.15.0@sha256:c418ccbc52ef7d2aef66ad3df778138d668c2bd612030f897f5f5f1081b8a2c6 as builder
ARG TARGETARCH
ARG VENDOR
ARG VERSION

USER root
WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
    && rm -rf /var/lib/apt/lists/* /tmp/*

RUN git clone --recursive https://github.com/DasRaschloch/deemix-gui.git

WORKDIR /app/deemix-gui

RUN yarn install-all

RUN yarn dist-server

FROM ghcr.io/trueforge-org/ubuntu:24.04@sha256:bec52e97e32c21da9b7f6f425804460202895214a0d1c18c103aa120d497c9d2
ARG TARGETARCH
ARG VENDOR
ARG VERSION

USER root
WORKDIR /app

USER apps

COPY --from=builder /app/deemix-gui/dist/deemix-server-linux /app/deemix-server

COPY --from=builder /app/deemix-gui/docker/ /app/

COPY --chmod=0755 . /

EXPOSE 6595

WORKDIR /config
