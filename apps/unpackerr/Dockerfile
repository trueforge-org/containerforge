

FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:17312da6b52fe7ab6e3bdc8e4a1f99df63c2494b2bad4f4b634a9065d585898e
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
