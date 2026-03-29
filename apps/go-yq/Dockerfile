## TODO: also make go-yq container
FROM ghcr.io/trueforge-org/python:3.13.12@sha256:b2e54139e48b5c65b3364beab48564f591ca52f9984a91d880e2ec32d7f29e85

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
