FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:14fdd75a2018ad4e7fafcc60a29d4f389657f7faedbb277f8a91de858c6113f2

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
