## TODO: also make go-yq container
FROM ghcr.io/trueforge-org/python:3.13.12@sha256:00bb62757540babe6b6ed56afef7816c6ab762f584fdfc0d0961cd53ea1de812

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
