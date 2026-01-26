## TODO: also make go-yq container
FROM ghcr.io/trueforge-org/python:3.13.7@sha256:28879e692c9ef5264f2bc23dc0cb2ff1402c276b2126309e00eb097ee5ebc1a1

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN echo "*** Installing go-yq ***" && \
    mkdir -p /app && \
    curl -L -o /app/yq \
        "https://github.com/mikefarah/yq/releases/download/v${VERSION}/yq_linux_${TARGETARCH}" && \
    chmod 755 /app/yq && \
    chown apps:apps /app/yq && \
    cp -f /app/yq /usr/bin/yq

USER apps
