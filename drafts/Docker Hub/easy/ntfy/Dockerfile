FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config

RUN echo "*** Installing ntfy ***" && \
  case "${TARGETARCH}" in \
    amd64|arm64) ;; \
    *) echo "unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  base="https://github.com/binwiederhier/ntfy/releases/download/v${VERSION}" && \
  curl -fsSL -o /tmp/ntfy.tar.gz \
    "${base}/ntfy_${VERSION}_linux_${TARGETARCH}.tar.gz" && \
  curl -fsSL -o /tmp/checksums.txt \
    "${base}/checksums.txt" && \
  (cd /tmp && grep " ntfy_${VERSION}_linux_${TARGETARCH}\.tar\.gz\$" checksums.txt | sha256sum -c -) && \
  mkdir -p /tmp/ntfy && \
  tar xzf /tmp/ntfy.tar.gz --strip-components=1 -C /tmp/ntfy && \
  install -m 0755 /tmp/ntfy/ntfy /app/ntfy && \
  mkdir -p /usr/share/licenses/ntfy && \
  cp /tmp/ntfy/LICENSE /usr/share/licenses/ntfy/LICENSE && \
  curl -fsSL -o /usr/share/licenses/ntfy/LICENSE.GPLv2 \
    "https://raw.githubusercontent.com/binwiederhier/ntfy/v${VERSION}/LICENSE.GPLv2" && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config
