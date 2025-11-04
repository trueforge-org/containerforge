# syntax=docker/dockerfile:1

FROM ghcr.io/trueforge-org/ubuntu:24.04.0@sha256:665ed0fd948cf3c093cb8e3fbf7f3add2a14915814322a302bb6bb3f4e25726a
ARG TARGETARCH
ARG VERSION

# Normalize architecture names
ARG TARGETARCH=${TARGETARCH/arm64/ARM64}
ARG TARGETARCH=${TARGETARCH/amd64/AMDx64}

USER root

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN mkdir -p /app/bin && \
    curl -fsSL "https://github.com/Jackett/Jackett/releases/download/${VERSION}/Jackett.Binaries.Linux${TARGETARCH}.tar.gz" \
        | tar xzf - -C /app/bin --strip-components=1 && \
    chown -R root:root /app && chmod -R 755 /app && \
    rm -rf /var/lib/apt/lists/* /tmp/* /app/bin/JackettUpdater*

USER nobody:nogroup

COPY --chmod=0775 . /

WORKDIR /config
