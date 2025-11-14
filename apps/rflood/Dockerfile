

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:aba163fade18b21ae0132813e7522fbd005a1cdc8818e308679480a78ba93bb9
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
