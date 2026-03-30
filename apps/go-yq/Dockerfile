## TODO: also make go-yq container
FROM ghcr.io/trueforge-org/python:3.13.12@sha256:cc5a5a300743bf95669130b982874279d999d8ac2691788c9c83f9493adb5bdf

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
