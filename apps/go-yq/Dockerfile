## TODO: also make go-yq container
FROM ghcr.io/trueforge-org/python:3.13.12@sha256:d9b5d12c8e22d9b84df211da15c73e7e2b36441675f00bba2c706f93526c602b

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
