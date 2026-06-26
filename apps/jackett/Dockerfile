

FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:e566b6c11ab30372ddb0ee460a2f65699fd50ad2eb148ddac0d7800074159f19
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

WORKDIR /config
