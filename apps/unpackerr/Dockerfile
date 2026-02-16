

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:9a693d4ad7151ab7bd13b94e6c6137b90dabf6d44280a1aad6e4a65e191749d2
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
