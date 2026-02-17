
FROM ghcr.io/trueforge-org/node:22.22.0@sha256:c33b4f5d240fa3273f3a5181a59d9c69e0f9e00124306fecfac68bd243ad8c34 as builder
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

FROM ghcr.io/trueforge-org/ubuntu:24.04@sha256:e96499687b5d1319878f006ab22dfdfcbfb7c059fc2d4538685636e026b71e87
ARG TARGETARCH
ARG VENDOR
ARG VERSION

USER root
WORKDIR /app

USER apps

COPY --from=builder /app/deemix-gui/dist/deemix-server-linux /app/deemix-server

COPY --from=builder /app/deemix-gui/docker/ /app/

COPY . /

EXPOSE 6595

WORKDIR /config
