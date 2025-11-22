## TODO: also make go-yq container
FROM ghcr.io/trueforge-org/python:3.13.7@sha256:7f3a002d8125a23f160f8f78ce367051200d136d2424bb028b5b55d2cfc5b6a3

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
