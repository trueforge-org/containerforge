FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:68e4815a37ff22f61b5f6bcd8f3ae25804632b5fe0f77ad11f6ddf0a8173aa60

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
