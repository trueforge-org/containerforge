FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV HOME=/config

# UNVERIFIED: upstream publishes no checksum file for the release zip; integrity rests on HTTPS and the pinned version
RUN set -eux; \
  case "${TARGETARCH}" in \
    amd64|arm64) ARCH="${TARGETARCH}" ;; \
    *) echo "unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
  esac; \
  echo "*** Installing mosdns ***"; \
  curl -fsSL -o /tmp/mosdns.zip \
    "https://github.com/IrineSistiana/mosdns/releases/download/v${VERSION}/mosdns-linux-${ARCH}.zip"; \
  unzip -q /tmp/mosdns.zip -d /tmp/mosdns; \
  install -m 0755 /tmp/mosdns/mosdns /app/mosdns; \
  echo "*** Installing license ***"; \
  mkdir -p /usr/share/licenses/mosdns; \
  cp /tmp/mosdns/LICENSE /usr/share/licenses/mosdns/; \
  echo "*** Cleaning Up ***"; \
  chown -R apps:apps /app; \
  chmod -R 755 /app; \
  rm -rf /tmp/mosdns /tmp/mosdns.zip

USER apps
COPY --chmod=0755 . /

EXPOSE 5353/tcp 5353/udp

VOLUME /config
