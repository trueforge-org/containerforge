
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config \
  RECYCLARR_CONFIG_DIR=/config \
  CRON_SCHEDULE=@daily \
  RECYCLARR_CREATE_CONFIG=false \
  COMPlus_EnableDiagnostics=0 \
  PATH="${PATH}:/app/recyclarr"

# UNVERIFIED: no upstream checksum is published for v8.8.1. The download relies on HTTPS and the pinned version.
RUN echo "*** Installing Recyclarr ***" && \
  case "${TARGETARCH}" in \
    amd64) RECYCLARR_ARCH="x64" ;; \
    arm64) RECYCLARR_ARCH="arm64" ;; \
    *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
  esac && \
  if ! command -v xz >/dev/null 2>&1; then \
    apt-get update && \
    apt-get install -y --no-install-recommends xz-utils && \
    rm -rf /var/lib/apt/lists/*; \
  fi && \
  mkdir -p /app/recyclarr && \
  curl -o \
    /tmp/recyclarr.tar.xz -L \
    "https://github.com/recyclarr/recyclarr/releases/download/v${VERSION}/recyclarr-linux-${RECYCLARR_ARCH}.tar.xz" && \
  tar xJf \
    /tmp/recyclarr.tar.xz -C \
    /app/recyclarr/ && \
  chmod 0755 /app/recyclarr/recyclarr && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  echo "*** Cleaning Up ***" && \
  rm -f /tmp/recyclarr.tar.xz

USER apps
COPY --chmod=0755 . /

VOLUME /config

CMD ["/start.sh"]
