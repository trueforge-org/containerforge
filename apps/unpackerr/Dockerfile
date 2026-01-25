

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:431129004c8b82702e6a1c82ffc20d64c770179547c8d77deb7133c314a6d3b8
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
