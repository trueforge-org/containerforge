

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:5e17d35aea5a235316958f3cb7d6c4ea7fb2026199c797d66e4a2b91eef2db51
ARG VERSION
ARG TARGETOS
ARG TARGETARCH
ARG TARGETPLATFORM

USER root

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        smartmontools \
    && \
    rm -rf /var/lib/apt/lists/*

# Download and install smartctl_exporter
RUN wget "https://github.com/prometheus-community/smartctl_exporter/releases/download/v$VERSION/smartctl_exporter-$VERSION.$TARGETOS-$TARGETARCH.tar.gz" && \
    tar xvzf smartctl_exporter-$VERSION.$TARGETOS-$TARGETARCH.tar.gz && \
    mv smartctl_exporter-$VERSION.$TARGETOS-$TARGETARCH/smartctl_exporter /usr/local/bin/smartctl_exporter && \
    chmod +x /usr/local/bin/smartctl_exporter && \
    rm -rf smartctl_exporter*

USER apps:apps

ENTRYPOINT ["/usr/local/bin/smartctl_exporter"]
