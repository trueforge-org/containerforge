## TODO: also make go-yq container
FROM ghcr.io/trueforge-org/python:3.13.7@sha256:cbb27d8be6746edc1ba1b6abc502a3ce311948e4e9025c73b7dee50c6a1bbd0d

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
