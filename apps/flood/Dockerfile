FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:2af39d611d60d6419c1f71c99d2beb94146c20dd28738763a8168a4421e4bf9d

ARG TARGETARCH
ARG VENDOR
ARG VERSION

USER root
WORKDIR /app

EXPOSE 3000 4500

# Install Flood
ARG FLOOD_VERSION
RUN curl -fsSL "https://github.com/jesec/flood/releases/download/v${VERSION}/flood-linux-x64" -o "/app/flood" && \
    chmod 755 "/app/flood" && \
    chown -R apps:apps /app

COPY . /

USER apps:apps
WORKDIR /config
