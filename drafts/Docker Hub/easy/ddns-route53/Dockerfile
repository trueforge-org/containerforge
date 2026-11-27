
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV HOME=/config

# The release tarball is a static Go binary. The sha256 is checked against the release's checksums.txt.
RUN echo "*** Installing ddns-route53 ***" && \
  mkdir -p /tmp/ddns /usr/share/licenses/ddns-route53 && \
  cd /tmp/ddns && \
  curl -fsSLO "https://github.com/crazy-max/ddns-route53/releases/download/v${VERSION}/ddns-route53_${VERSION}_linux_${TARGETARCH}.tar.gz" && \
  curl -fsSLO "https://github.com/crazy-max/ddns-route53/releases/download/v${VERSION}/checksums.txt" && \
  grep " \*\?ddns-route53_${VERSION}_linux_${TARGETARCH}.tar.gz\$" checksums.txt | sed 's/ \*/  /' | sha256sum -c - && \
  tar -xzf "ddns-route53_${VERSION}_linux_${TARGETARCH}.tar.gz" && \
  install -m 0755 ddns-route53 /app/ddns-route53 && \
  cp LICENSE /usr/share/licenses/ddns-route53/LICENSE && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  rm -rf /tmp/ddns

USER apps
COPY --chmod=0755 . /

VOLUME /config
