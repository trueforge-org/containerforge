## TODO: also make go-yq container
FROM ghcr.io/trueforge-org/python:3.13.12@sha256:32f90bc0c1f522ce2b2ffdef58e2a781e5fb71b9c7c90c0de92b516f493f7518

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
