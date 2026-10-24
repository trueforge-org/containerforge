## TODO: also make go-yq container
FROM ghcr.io/trueforge-org/python:3.15.1@sha256:fcc611b0d03ab808bdce505d2d2524c941ec5d2314ef3eb0b63c43d22bd6a2b2

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
COPY --chmod=0755 . /
