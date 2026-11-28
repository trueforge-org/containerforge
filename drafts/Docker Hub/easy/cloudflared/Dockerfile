FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/tmp \
  NO_AUTOUPDATE=true

# Static Go binary, so the release asset is used as is (no compile stage).
# Checksum comes from the release page "Checksums:" block (see plan section 4).
RUN echo "*** Installing cloudflared ***" && \
  curl -fsSLo /app/cloudflared \
    "https://github.com/cloudflare/cloudflared/releases/download/${VERSION}/cloudflared-linux-${TARGETARCH}" && \
  expected="$(curl -fsSL "https://github.com/cloudflare/cloudflared/releases/tag/${VERSION}" | grep -o -E "cloudflared-linux-${TARGETARCH}: [0-9a-f]{64}" | head -n1 | cut -d' ' -f2)" && \
  test -n "${expected}" && \
  echo "${expected}  /app/cloudflared" | sha256sum -c - && \
  chmod 0755 /app/cloudflared && \
  chown -R apps:apps /app && \
  echo "*** Adding license ***" && \
  mkdir -p /usr/share/licenses/cloudflared && \
  curl -fsSLo /usr/share/licenses/cloudflared/LICENSE \
    "https://raw.githubusercontent.com/cloudflare/cloudflared/${VERSION}/LICENSE"

USER apps
COPY --chmod=0755 . /

EXPOSE 20241

VOLUME /config
