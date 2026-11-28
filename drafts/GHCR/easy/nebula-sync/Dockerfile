
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  API_ENABLED=true

# Upstream publishes checksums.txt per release; the tarball is verified against it before extraction.
RUN echo "*** Installing nebula-sync ***" && \
  mkdir -p /tmp/nebula-sync-dl /tmp/nebula-sync-x /usr/share/licenses/nebula-sync && \
  cd /tmp/nebula-sync-dl && \
  curl -fL -o checksums.txt \
    "https://github.com/lovelaze/nebula-sync/releases/download/v${VERSION}/checksums.txt" && \
  curl -fL -O \
    "https://github.com/lovelaze/nebula-sync/releases/download/v${VERSION}/nebula-sync_${VERSION}_linux_${TARGETARCH}.tar.gz" && \
  grep " nebula-sync_${VERSION}_linux_${TARGETARCH}.tar.gz$" checksums.txt > expected.sha256 && \
  test -s expected.sha256 && \
  sha256sum -c expected.sha256 && \
  tar xzf "nebula-sync_${VERSION}_linux_${TARGETARCH}.tar.gz" -C /tmp/nebula-sync-x && \
  install -m 0755 /tmp/nebula-sync-x/nebula-sync /app/nebula-sync && \
  curl -fL -o /usr/share/licenses/nebula-sync/LICENSE \
    "https://raw.githubusercontent.com/lovelaze/nebula-sync/v${VERSION}/LICENSE" && \
  echo "*** Cleaning Up ***" && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  rm -rf /tmp/nebula-sync-dl /tmp/nebula-sync-x

USER apps
COPY --chmod=0755 . /

VOLUME /config
