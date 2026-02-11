
FROM ghcr.io/trueforge-org/node:22.20.0@sha256:ddd2e92871c2738c4b20cee69e8423049698d6da5f1a9ef910a6acd30e547fed as builder
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

FROM ghcr.io/trueforge-org/ubuntu:24.04@sha256:3b826c0233182d7c31a9323121178b98976765b9ee03f9a96200ab0c70e2e1e2
ARG TARGETARCH
ARG VENDOR
ARG VERSION

USER root
WORKDIR /app

USER apps:apps

COPY --from=builder /app/deemix-gui/dist/deemix-server-linux /app/deemix-server

COPY --from=builder /app/deemix-gui/docker/ /app/

COPY . /

EXPOSE 6595

WORKDIR /config
