

FROM ghcr.io/trueforge-org/ubuntu:24.4.0@sha256:654a659958d368fa2e5f1aca4a24347c3e58f2c9c5194e1d07e3abaeb539ac32
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

USER apps
COPY --chmod=0755 . /

ENTRYPOINT ["/usr/local/bin/smartctl_exporter"]
