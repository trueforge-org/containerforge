## TODO: also make go-yq container
FROM ghcr.io/trueforge-org/python:3.13.12@sha256:cafd0ad53f7161279ed136289e277fbf53f5ed3fe1d51cf66f1892ec846bd772

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
