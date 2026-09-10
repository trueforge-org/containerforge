## TODO: also make go-yq container
FROM ghcr.io/trueforge-org/python:3.14.7@sha256:1b4e02f5ae67a789aaf0f3d0d059a6eee7da28a9998c7018070edff055aff72a

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
