## TODO: also make go-yq container
FROM ghcr.io/trueforge-org/python:3.13.7@sha256:9339a4781b93a9baa1cd0378613939fc7fedcd032f0852fc7680688ab655f533

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
