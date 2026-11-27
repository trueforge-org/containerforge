
# Split draft (web + collector, no embedded InfluxDB, no s6) from plan.md section 4. UNVERIFIED items are marked inline.
# No checksum is published with the v0.10.0 release assets; record sha256 after the first download (plan section 4).
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG TARGETARCH
USER root

ENV HOME=/config

RUN case "${TARGETARCH}" in amd64|arm64) ;; *) echo "Unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; esac

# Requires privileged access and raw device passthrough at runtime for SMART data (plan section 9 and 10).
RUN echo "*** Installing Scrutiny ***" && \
  apt-get update && apt-get install -y --no-install-recommends \
    smartmontools && \
  rm -rf /var/lib/apt/lists/* && \
  mkdir -p /app/bin /app/web && \
  curl -fL -o /app/bin/scrutiny-web \
    "https://github.com/AnalogJ/scrutiny/releases/download/v${VERSION}/scrutiny-web-linux-${TARGETARCH}" && \
  curl -fL -o /app/bin/scrutiny-collector-metrics \
    "https://github.com/AnalogJ/scrutiny/releases/download/v${VERSION}/scrutiny-collector-metrics-linux-${TARGETARCH}" && \
  chmod 0755 /app/bin/scrutiny-web /app/bin/scrutiny-collector-metrics && \
  curl -fL -o /tmp/scrutiny-frontend.tar.gz \
    "https://github.com/AnalogJ/scrutiny/releases/download/v${VERSION}/scrutiny-web-frontend.tar.gz" && \
  # UNVERIFIED: the frontend tarball layout (whether it contains a dist/ folder) must be confirmed on the first build.
  tar xzf /tmp/scrutiny-frontend.tar.gz -C /app/web && \
  rm /tmp/scrutiny-frontend.tar.gz && \
  mkdir -p /usr/share/licenses/scrutiny && \
  curl -fL -o /usr/share/licenses/scrutiny/LICENSE \
    "https://raw.githubusercontent.com/AnalogJ/scrutiny/v${VERSION}/LICENSE" && \
  chown -R apps:apps /app && \
  chmod -R 755 /app && \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config
WORKDIR /app
