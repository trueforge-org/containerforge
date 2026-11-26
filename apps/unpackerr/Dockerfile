

FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a
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
