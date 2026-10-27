
FROM ghcr.io/trueforge-org/node:24.22.1@sha256:7b7273ef83088a8ce734cd4933fe3ab1c1faf478173d2d04cb3a22ea1e7a3bf7 as builder
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

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:9ec5de91a1fb401ba4739f36a6b8dfaf70fd8dc75735fdf608e23392f9be29ba
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
