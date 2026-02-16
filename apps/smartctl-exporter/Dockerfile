

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:5348eb7725294e8090c15b7b495e517f82f4b31497d3bb9de71bbe37476e7454
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
