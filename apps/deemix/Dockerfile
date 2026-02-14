
FROM ghcr.io/trueforge-org/node:22.22.0@sha256:c0dc57295c677e6b1341544d1b89a2254ddebd07c55840c491be19b3bc3bec37 as builder
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

FROM ghcr.io/trueforge-org/ubuntu:24.04@sha256:ede54cb88fd5efef6f41610146f10b4399f5e584d9227202b6c14a515a35e94e
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
