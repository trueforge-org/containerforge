## TODO: also make go-yq container
FROM ghcr.io/trueforge-org/python:3.14.7@sha256:05a7bc16dd8486cbe36714903407947136771e66de31cf93d562200e8a665def

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
