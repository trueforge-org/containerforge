

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:91d978bcece60398d9a21a2f331801d9004f5651a323f8f25ed2fa70b5d8eacd
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
