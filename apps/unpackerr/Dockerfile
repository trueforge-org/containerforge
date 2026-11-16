

FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:6694765a55a999799d0b37f806a0e0ba11ceb4dcb22392b63f1b74b4123ea175
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
