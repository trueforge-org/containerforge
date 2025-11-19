

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:2af39d611d60d6419c1f71c99d2beb94146c20dd28738763a8168a4421e4bf9d
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

USER apps:apps

COPY --chmod=0775 . /

WORKDIR /config
