FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
# Release asset digests from the GitHub releases API (v1.0.0). No checksum file is published in the release.
ARG SHA256_AMD64="2c31fa4bb8e99516d4f3ea97ef9a595b3adeff0d1923886182aef1c8cdc96cf9"
ARG SHA256_ARM64="95107e5fb1393e73640e2fbde9eda0919a46086e1c03b46207765a0f3dc9c7ed"

USER root

ENV \
  HOME=/config

RUN echo "*** Installing zurg ${VERSION} ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends unzip && \
  case "${TARGETARCH}" in \
    amd64) SHA256="${SHA256_AMD64}" ;; \
    arm64) SHA256="${SHA256_ARM64}" ;; \
    *) echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  curl -fsSL -o /tmp/zurg.zip \
    "https://github.com/debridmediamanager/zurg-public/releases/download/v${VERSION}/zurg-v${VERSION}-linux-${TARGETARCH}.zip" && \
  echo "${SHA256}  /tmp/zurg.zip" | sha256sum -c - && \
  mkdir -p /app/zurg && \
  unzip -o /tmp/zurg.zip zurg -d /app/zurg && \
  chmod 0755 /app/zurg/zurg && \
  chown -R root:root /app && chmod -R 755 /app && \
  echo "*** Cleaning Up ***" && \
  rm -rf /tmp/zurg.zip /var/lib/apt/lists/*

USER apps
COPY --chmod=0755 . /
WORKDIR /config

EXPOSE 9999

VOLUME /config
