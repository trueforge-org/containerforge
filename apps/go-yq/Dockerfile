## TODO: also make go-yq container
FROM ghcr.io/trueforge-org/python:3.13.7@sha256:9a1dfe6b3eee6522edf77799d5468374d33f85e46305177c062bf72210b61767

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
