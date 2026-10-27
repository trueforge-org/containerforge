FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:9ec5de91a1fb401ba4739f36a6b8dfaf70fd8dc75735fdf608e23392f9be29ba

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


USER apps
COPY --chmod=0755 . /
WORKDIR /config
