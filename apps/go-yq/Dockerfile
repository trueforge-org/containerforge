## TODO: also make go-yq container
FROM ghcr.io/trueforge-org/python:3.13.7@sha256:3664bd10fe22328f1b7d6d1002a074b6bbfc78b7688200388230f49190d622e2

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
