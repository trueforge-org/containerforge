

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:e96499687b5d1319878f006ab22dfdfcbfb7c059fc2d4538685636e026b71e87
ARG TARGETARCH
ARG VENDOR
ARG VERSION

USER root
WORKDIR /app

RUN curl -fsSL "https://github.com/Unpackerr/unpackerr/releases/download/v${VERSION}/unpackerr.${TARGETARCH}.linux.gz" \
        | gunzip > /app/unpackerr && \
    chmod +x /app/unpackerr && \
    chmod -R u=rwX,go=rX /app && \
    chown -R apps:apps /app

COPY . /

USER apps
WORKDIR /config
