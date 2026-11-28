FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config \
  LOCALAI_ADDRESS=0.0.0.0:8080 \
  LOCALAI_MODELS_PATH=/config/models \
  LOCALAI_BACKENDS_PATH=/config/backends \
  LOCALAI_DATA_PATH=/config/data \
  LOCALAI_CONFIG_DIR=/config/configuration \
  LOCALAI_GENERATED_CONTENT_PATH=/config/generated \
  LOCALAI_DOWNLOAD_STAGING_PATH=/config/downloading \
  LOCALAI_UPLOAD_PATH=/tmp/upload

# Verify the binary against the release checksum file. Upstream's entrypoint runs as root and drops to uid 10001;
# this image runs as apps instead, so no entrypoint is copied.
RUN echo "*** Installing LocalAI ${VERSION} ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    espeak-ng \
    libgomp1 && \
  rm -rf /var/lib/apt/lists/* && \
  cd /tmp && \
  curl -fsSL -o local-ai \
    "https://github.com/mudler/LocalAI/releases/download/v${VERSION}/local-ai-v${VERSION}-linux-${TARGETARCH}" && \
  curl -fsSL -o sums.txt \
    "https://github.com/mudler/LocalAI/releases/download/v${VERSION}/LocalAI-v${VERSION}-checksums.txt" && \
  grep -E "[[:space:]]local-ai-v${VERSION}-linux-${TARGETARCH}\$" sums.txt | awk '{print $1"  local-ai"}' | sha256sum -c - && \
  install -m 0755 local-ai /app/local-ai && \
  rm -f /tmp/local-ai /tmp/sums.txt

RUN echo "*** Collecting license ***" && \
  mkdir -p /usr/share/licenses/local-ai && \
  curl -fsSL -o /usr/share/licenses/local-ai/LICENSE \
    "https://raw.githubusercontent.com/mudler/LocalAI/v${VERSION}/LICENSE" && \
  chmod -R a+rX /app

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config
WORKDIR /config
