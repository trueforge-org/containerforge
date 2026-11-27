FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config \
  GODEBUG=multipathtcp=0

RUN echo "*** Installing unzip ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    unzip && \
  rm -rf /var/lib/apt/lists/*

# The release zip ships the prebuilt binary. It is verified with the .sha256 inside the zip,
# which only proves the zip is intact. Authenticity (GPG .sig) is not checked yet.
RUN echo "*** Installing Vikunja ***" && \
  V="${VERSION#v}" && \
  mkdir -p /tmp/vk /app/vikunja /usr/share/licenses/vikunja && \
  curl -fsSL -o /tmp/vikunja.zip \
    "https://github.com/go-vikunja/vikunja/releases/download/v${V}/vikunja-v${V}-linux-${TARGETARCH}-full.zip" && \
  unzip -q /tmp/vikunja.zip -d /tmp/vk && \
  (cd /tmp/vk && sha256sum -c "vikunja-v${V}-linux-${TARGETARCH}.sha256") && \
  install -m 0755 "/tmp/vk/vikunja-v${V}-linux-${TARGETARCH}" /app/vikunja/vikunja && \
  cp /tmp/vk/LICENSE /usr/share/licenses/vikunja/LICENSE && \
  cp /tmp/vk/config.yml.sample /app/vikunja/config.yml.sample && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 3456

VOLUME /config

WORKDIR /config
