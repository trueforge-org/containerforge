

FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:f5810a8898e3c4010e9609799c2cc0ef871d42a7637fbdd77f2c62c1e67b495c
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
