

FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:a3ec289cfc10acc23a20cfb4fe5033c944ce3073dc4a53157c093ffb52f983b1
ARG TARGETARCH
ARG VENDOR
ARG VERSION

USER root
WORKDIR /app

RUN curl -fsSL "https://github.com/Unpackerr/unpackerr/releases/download/v${VERSION}/unpackerr_${VERSION}_linux_${TARGETARCH}.tar.gz" \
        -o /tmp/unpackerr.tar.gz && \
    tar -xzf /tmp/unpackerr.tar.gz -C /tmp unpackerr && \
    mv /tmp/unpackerr /app/unpackerr && \
    rm /tmp/unpackerr.tar.gz && \
    chmod +x /app/unpackerr && \
    chmod -R u=rwX,go=rX /app && \
    chown -R apps:apps /app


USER apps
COPY --chmod=0755 . /
WORKDIR /config
