
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# set version label
ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config \
  OTEL_TRACES_EXPORTER=none

RUN \
  echo "**** download docker registry ****" && \
  curl -fsSL -o /tmp/registry.tar.gz \
    "https://github.com/distribution/distribution/releases/download/${VERSION}/registry_${VERSION#v}_linux_${TARGETARCH}.tar.gz" && \
  curl -fsSL -o /tmp/registry.tar.gz.sha256 \
    "https://github.com/distribution/distribution/releases/download/${VERSION}/registry_${VERSION#v}_linux_${TARGETARCH}.tar.gz.sha256" && \
  echo "$(cat /tmp/registry.tar.gz.sha256)  /tmp/registry.tar.gz" | sha256sum -c - && \
  tar xzf /tmp/registry.tar.gz -C /tmp registry LICENSE && \
  install -m 0755 /tmp/registry /app/registry && \
  mkdir -p /usr/share/licenses/dockerregistry && \
  cp /tmp/LICENSE /usr/share/licenses/dockerregistry/LICENSE && \
  echo "**** cleanup ****" && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  rm -f /tmp/registry.tar.gz /tmp/registry.tar.gz.sha256 /tmp/registry /tmp/LICENSE

# copy local files
USER apps
COPY --chmod=0755 . /

EXPOSE 5000

VOLUME /config
