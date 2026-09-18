
FROM ghcr.io/trueforge-org/node:24.21.0@sha256:8a3b1492643536ff84b8e06fbe93fddd49acc1e31ff4df4141dbb3be62fb7e6a as builder
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

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:2f8d64c7eb825345ac24192c13f028804662cb3d6cc633df9dd8f394e042f738
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
