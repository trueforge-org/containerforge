
FROM ghcr.io/trueforge-org/node:22.22.0@sha256:299642a3cabfc8e29c799b2cddbabc437a4cac6f8d4ca6caa52cf245ed4e464c as builder
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

FROM ghcr.io/trueforge-org/ubuntu:24.04@sha256:3209530ed3169bb7c62c9010745abf292a4bcbe5b8757787aebcce488c09d520
ARG TARGETARCH
ARG VENDOR
ARG VERSION

USER root
WORKDIR /app

USER apps
COPY container-test.yaml /container-test.yaml

COPY --from=builder /app/deemix-gui/dist/deemix-server-linux /app/deemix-server

COPY --from=builder /app/deemix-gui/docker/ /app/

COPY . /

EXPOSE 6595

WORKDIR /config
