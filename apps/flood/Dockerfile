FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:e96499687b5d1319878f006ab22dfdfcbfb7c059fc2d4538685636e026b71e87

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

USER apps
WORKDIR /config
