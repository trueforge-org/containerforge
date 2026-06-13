## TODO: also make go-yq container
FROM ghcr.io/trueforge-org/python:3.14.6@sha256:d68fb2080f1cf876f37992bdb39d84a71ae30f745f4c82b31c06b07d5f4bcad3

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
