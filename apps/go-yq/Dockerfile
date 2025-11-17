## TODO: also make go-yq container
FROM ghcr.io/trueforge-org/python:3.13.7

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN echo "*** Installing go-yq ***" && \
  curl -o \
    /app -L \
    "https://github.com/mikefarah/yq/releases/download/v${version}/yq_linux_${TARGETARCH}" && \
    mv /app/yq_linux_${TARGETARCH} /app/yq && \
    chown apps:apps /app/yq && chmod +x /app/yq && \
    cp -rf /app/yq /usr/bin/yq

USER apps
