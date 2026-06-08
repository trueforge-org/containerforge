## TODO: also make go-yq container
FROM ghcr.io/trueforge-org/python:3.14.5@sha256:b87e7b85aa5b5451e8b38f0f2b67e8045cdec9ee76f8eeab4227fe8dbcb2eefa

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
