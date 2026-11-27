FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH

USER root

# The release tarball is checked against the release checksum file before the binary is installed.
RUN echo "*** Installing mc-router ${VERSION} ***" && \
  mkdir -p /tmp/mc-router && \
  cd /tmp/mc-router && \
  curl -fLO "https://github.com/itzg/mc-router/releases/download/v${VERSION}/mc-router_${VERSION}_linux_${TARGETARCH}.tar.gz" && \
  curl -fLO "https://github.com/itzg/mc-router/releases/download/v${VERSION}/mc-router_${VERSION}_checksums.txt" && \
  grep -F "mc-router_${VERSION}_linux_${TARGETARCH}.tar.gz" "mc-router_${VERSION}_checksums.txt" | sha256sum -c - && \
  tar xzf "mc-router_${VERSION}_linux_${TARGETARCH}.tar.gz" mc-router LICENSE.txt && \
  install -d /app /usr/share/licenses/minecraft-router && \
  install -m 0755 mc-router /app/mc-router && \
  install -m 0644 LICENSE.txt /usr/share/licenses/minecraft-router/LICENSE && \
  cd / && \
  rm -rf /tmp/mc-router

ENV HOME=/config

USER apps
COPY --chmod=0755 . /

EXPOSE 25565

VOLUME /config
