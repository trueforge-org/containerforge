## TODO: also make go-yq container
FROM ghcr.io/trueforge-org/python:3.13.12@sha256:d0392caa927c7c5f3d2e75b31098faa3cebad8d7c311fe7dfd0d074270418422

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
