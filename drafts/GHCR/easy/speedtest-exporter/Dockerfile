FROM ghcr.io/trueforge-org/python:3.15.2@sha256:064e0c7d1d04ba647bfd1f91e2bee22b8f8d1ad91e00997f3eae4deea94d2e9d

ARG VERSION
ARG TARGETARCH
ARG SPEEDTEST_VERSION=1.2.0

ENV \
  SPEEDTEST_PORT=9798 \
  HOME=/tmp

USER root
WORKDIR /app

# Source is pinned by tag only: upstream publishes no checksum.
RUN echo "*** Installing Speedtest-Exporter ***" && \
  mkdir -p /tmp/src /usr/share/licenses/speedtest-exporter && \
  curl -fsSL -o /tmp/src.tar.gz \
    "https://github.com/MiguelNdeCarvalho/speedtest-exporter/archive/refs/tags/v${VERSION}.tar.gz" && \
  tar xzf /tmp/src.tar.gz -C /tmp/src --strip-components=1 && \
  cp -a /tmp/src/src/. /app/ && \
  cp /tmp/src/LICENSE /usr/share/licenses/speedtest-exporter/LICENSE && \
  pip install --no-cache-dir -r /app/requirements.txt && \
  rm -f /app/requirements.txt

# Ookla CLI: upstream publishes no checksum (UNVERIFIED). Redistribution terms are unconfirmed.
RUN echo "*** Installing Ookla Speedtest CLI ***" && \
  ARCH="$(case "${TARGETARCH}" in amd64) echo x86_64 ;; arm64) echo aarch64 ;; *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1 ;; esac)" && \
  curl -fsSL -o /tmp/speedtest.tgz \
    "https://install.speedtest.net/app/cli/ookla-speedtest-${SPEEDTEST_VERSION}-linux-${ARCH}.tgz" && \
  mkdir -p /tmp/speedtest-cli /usr/share/licenses/ookla-speedtest && \
  tar xzf /tmp/speedtest.tgz -C /tmp/speedtest-cli && \
  install -m 0755 /tmp/speedtest-cli/speedtest /usr/local/bin/speedtest && \
  for f in /tmp/speedtest-cli/*; do \
    case "$f" in */speedtest) ;; *) cp "$f" /usr/share/licenses/ookla-speedtest/ ;; esac; \
  done && \
  echo "*** Cleaning Up ***" && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 9798

VOLUME /config
