

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:b1fa023ff8e056bfe31075b3cfec6a5de5572e1eee730d1365d3893243d7163c
ARG TARGETARCH
ARG VENDOR
ARG VERSION

USER root
WORKDIR /app

# TODO readd chromaprint
RUN echo "test"

COPY . /

USER apps:apps
WORKDIR /config
