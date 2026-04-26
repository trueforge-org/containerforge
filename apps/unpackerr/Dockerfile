

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:fdcc4e24cd12eed53bb1338ab6dd5651f5326bcbb98920aa3e8f0c8f5c9b2458
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


USER apps
COPY --chmod=0755 . /
WORKDIR /config
