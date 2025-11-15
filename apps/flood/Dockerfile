FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:aba163fade18b21ae0132813e7522fbd005a1cdc8818e308679480a78ba93bb9

ARG TARGETARCH
ARG VENDOR
ARG VERSION

USER root
WORKDIR /app

EXPOSE 3000 5000

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    xmlrpc-c \
    nginx \
    openssl \
    mediainfo && \
    rm -rf /var/lib/apt/lists/* && \
    ln -s "/config/rpc2/basic_auth_credentials" "/app/basic_auth_credentials"

# Install Flood
ARG FLOOD_VERSION
RUN curl -fsSL "https://github.com/jesec/flood/releases/download/v${FLOOD_VERSION}/flood-linux-x64" -o "/app/flood" && \
    chmod 755 "/app/flood"

COPY . /

USER apps:apps
WORKDIR /config
