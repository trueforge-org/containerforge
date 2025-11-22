## TODO: also make go-yq container
FROM ghcr.io/trueforge-org/python:3.13.7@sha256:be294e0b693a9c982bd5d5f14c18b7181326eb9f47f2d05c4f8a0c2cc58b6709

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
