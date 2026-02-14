## TODO: also make go-yq container
FROM ghcr.io/trueforge-org/python:3.13.12@sha256:77449580f12ca47641798a11e38291c1e30b532818ea7809078c3fa6e9bfc4df

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
