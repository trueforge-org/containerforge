FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config \
  TRAGGO_DATABASE_CONNECTION=/config/traggo.db \
  TRAGGO_PORT=3030

# UNVERIFIED: the upstream release publishes no checksum asset, so integrity
# relies on the HTTPS download from the GitHub release.
RUN echo "*** Installing traggo ***" && \
  mkdir -p /app /usr/share/licenses/traggo && \
  curl -fsSL -o \
    /tmp/traggo.tar.gz \
    "https://github.com/traggo/server/releases/download/v${VERSION}/traggo_${VERSION}_linux_${TARGETARCH}.tar.gz" && \
  tar xzf \
    /tmp/traggo.tar.gz -C /app traggo && \
  tar xzf \
    /tmp/traggo.tar.gz -C /usr/share/licenses/traggo LICENSE && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  echo "*** Cleaning Up ***" && \
  rm /tmp/traggo.tar.gz

USER apps
COPY --chmod=0755 . /

WORKDIR /config

EXPOSE 3030

VOLUME /config
