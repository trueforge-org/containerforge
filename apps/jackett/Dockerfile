

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:8f6de6a5c28a657e36d1b7630580eaf27788aac5d0603d18d644a1ac1332f061
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

USER apps
COPY --chmod=0755 . /

COPY --chmod=0775 . /

WORKDIR /config
