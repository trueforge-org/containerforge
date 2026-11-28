FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV HOME=/config

RUN set -eux; \
  mkdir -p /usr/share/licenses/filebrowser; \
  base="https://github.com/filebrowser/filebrowser/releases/download/v${VERSION}"; \
  curl -fsSL -o /tmp/fb.tar.gz "${base}/linux-${TARGETARCH}-filebrowser.tar.gz"; \
  curl -fsSL -o /tmp/checksums.txt "${base}/filebrowser_${VERSION}_checksums.txt"; \
  (cd /tmp && grep " linux-${TARGETARCH}-filebrowser.tar.gz\$" checksums.txt | sha256sum -c -); \
  tar -xzf /tmp/fb.tar.gz -C /app filebrowser; \
  tar -xzf /tmp/fb.tar.gz -C /usr/share/licenses/filebrowser LICENSE README.md; \
  chown -R apps:apps /app; chmod -R 755 /app; \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 8080
VOLUME /config
VOLUME /data
