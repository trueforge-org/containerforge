
# UNVERIFIED base digest: the repo's trueforge ubuntu digest (shared with the other apps) is used here
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config

# Upstream publishes no checksum file for these zips (UNVERIFIED: integrity relies on HTTPS only).
# identity is shipped so the identity can be created with this same image.
RUN echo "*** Installing storj storagenode and identity ***" && \
  base="https://github.com/storj/storj/releases/download/v${VERSION}" && \
  for bin in storagenode identity; do \
    curl -fsSL -o "/tmp/${bin}.zip" "${base}/${bin}_linux_${TARGETARCH}.zip" && \
    unzip -o "/tmp/${bin}.zip" -d /app && \
    rm "/tmp/${bin}.zip"; \
  done && \
  chmod 0755 /app/storagenode /app/identity && \
  echo "*** Installing license ***" && \
  mkdir -p /usr/share/licenses/storj-node && \
  curl -fsSL -o /usr/share/licenses/storj-node/LICENSE \
    "https://raw.githubusercontent.com/storj/storj/v${VERSION}/LICENSE" && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 28967/tcp 28967/udp 14002/tcp

VOLUME /config
WORKDIR /config
