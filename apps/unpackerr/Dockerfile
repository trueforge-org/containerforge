

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:7f4b4dfea9fcd818103c5d1f64cd5135785977fc90927aab58d25a155f27be4a
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
