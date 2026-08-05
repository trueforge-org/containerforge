## TODO: also make go-yq container
FROM ghcr.io/trueforge-org/python:3.14.7@sha256:74252ae048ecabddaafe9eeb2cd08f8c9ea9ee0c09458a0f41c93d170d6ea9da

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
