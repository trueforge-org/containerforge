FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:5491a2f46a8408f4085d5b92ff59358bafd56e7f26058b30347bfdefa568ed8a

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
