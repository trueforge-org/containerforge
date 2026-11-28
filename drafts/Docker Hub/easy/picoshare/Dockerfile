FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
# Litestream is intentionally held at 0.3.13: 0.5 changed the config format.
ARG LITESTREAM_VERSION=0.3.13
USER root

ENV \
  HOME=/config \
  LITESTREAM_PATH=db \
  LITESTREAM_RETENTION=72h

# UNVERIFIED: picoshare publishes no checksum file for the app tarball, so it
# relies on HTTPS. Litestream is checked against the sha256 values computed from
# the release assets (see plan).
RUN echo "*** Installing PicoShare ***" && \
  mkdir -p /app /usr/share/licenses/picoshare && \
  curl -fsSL -o \
    /tmp/picoshare.tar.gz \
    "https://github.com/mtlynch/picoshare/releases/download/v${VERSION}/picoshare-v${VERSION}-linux-${TARGETARCH}.tar.gz" && \
  tar xzf \
    /tmp/picoshare.tar.gz -C /app picoshare && \
  echo "*** Installing Litestream ***" && \
  case "${TARGETARCH}" in \
    amd64) LITESTREAM_SHA256="eb75a3de5cab03875cdae9f5f539e6aedadd66607003d9b1e7a9077948818ba0" ;; \
    arm64) LITESTREAM_SHA256="9585f5a508516bd66af2b2376bab4de256a5ef8e2b73ec760559e679628f2d59" ;; \
    *) echo "unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
  esac && \
  curl -fsSL -o \
    /tmp/litestream.tar.gz \
    "https://github.com/benbjohnson/litestream/releases/download/v${LITESTREAM_VERSION}/litestream-v${LITESTREAM_VERSION}-linux-${TARGETARCH}.tar.gz" && \
  echo "${LITESTREAM_SHA256}  /tmp/litestream.tar.gz" | sha256sum -c - && \
  tar xzf \
    /tmp/litestream.tar.gz -C /app litestream && \
  echo "*** Fetching licenses ***" && \
  curl -fsSL -o \
    /usr/share/licenses/picoshare/LICENSE \
    "https://raw.githubusercontent.com/mtlynch/picoshare/v${VERSION}/LICENSE" && \
  curl -fsSL -o \
    /usr/share/licenses/picoshare/LICENSE.litestream \
    "https://raw.githubusercontent.com/benbjohnson/litestream/v${LITESTREAM_VERSION}/LICENSE" && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  echo "*** Cleaning Up ***" && \
  rm -f /tmp/picoshare.tar.gz /tmp/litestream.tar.gz

USER apps
COPY --chmod=0755 . /

WORKDIR /config

EXPOSE 4001

VOLUME /config
