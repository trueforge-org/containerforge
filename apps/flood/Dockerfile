FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:ea16b55109312b5eda59cf3cdd576c10979b7532e0a9561de068b9679794ea33

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
