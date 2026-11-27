FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
# Checksums from the cloudflared 2026.1.2 release notes (taken from the plan; re-check before release).
ARG SHA256_AMD64=e157c54e929cc289cbd53860453168c2fe3439eb55e2e965a56579252585d9c1
ARG SHA256_ARM64=1362498b9975e018f290cc4412af61391cca65cccbc06f2d8b128324ae9a18ef
USER root

# VERSION must stay at 2026.1.2 or older: cloudflared 2026.2.0+ removed proxy-dns.
RUN echo "*** Installing cloudflared ${VERSION} ***" && \
  case "$TARGETARCH" in \
    amd64) SUM="$SHA256_AMD64" ;; \
    arm64) SUM="$SHA256_ARM64" ;; \
    *) echo "Unsupported architecture: $TARGETARCH" && exit 1 ;; \
  esac && \
  curl -fsSL -o /tmp/cloudflared \
    "https://github.com/cloudflare/cloudflared/releases/download/${VERSION}/cloudflared-linux-${TARGETARCH}" && \
  echo "${SUM}  /tmp/cloudflared" | sha256sum -c - && \
  install -D -m 0755 /tmp/cloudflared /app/cloudflared && \
  /app/cloudflared --version | grep -q "${VERSION}" && \
  install -d /usr/share/licenses/dns-doh-companion && \
  curl -fsSL -o /usr/share/licenses/dns-doh-companion/LICENSE \
    "https://raw.githubusercontent.com/cloudflare/cloudflared/${VERSION}/LICENSE" && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  rm -rf /tmp/*

ENV HOME=/tmp

USER apps
COPY --chmod=0755 . /

EXPOSE 5053/tcp 5053/udp

VOLUME /config
