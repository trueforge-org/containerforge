## TODO: also make go-yq container
FROM ghcr.io/trueforge-org/python:3.13.12@sha256:a6e9da280c86f6604e3f9174989b76d6453f6f94d249163049783eeb80118370

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
