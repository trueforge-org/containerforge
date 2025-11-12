# syntax=docker/dockerfile:1

FROM ghcr.io/trueforge-org/ubuntu:24.04
ARG TARGETARCH

# TODO automate grabbing version here: https://update.code.visualstudio.com/api/releases/stable
ARG VERSION

USER root

RUN apt-get update && \
    apt-get install -y git && \
    curl -sL "https://update.code.visualstudio.com/${VERSION}/linux-${TARGETARCH}/stable" \
        --output /tmp/vscode-cli.tar.gz && \
    tar -xf /tmp/vscode-cli.tar.gz -C /usr/bin && \
    rm /tmp/vscode-cli.tar.gz; \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER apps


USER nobody:nogroup

CMD [ "code", "tunnel", "--accept-server-license-terms" ]

WORKDIR /config
