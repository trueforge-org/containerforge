FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:c5a3b56e4d22600d2b618d602d487732516cc067cb21969798210c3b12304842

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
