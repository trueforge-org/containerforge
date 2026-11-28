FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config

# ffmpeg is needed for transcoding. Its version is not tied to VERSION, so it is not pinned.
# hadolint ignore=DL3008
RUN echo "*** Installing ffmpeg ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends ffmpeg && \
  rm -rf /var/lib/apt/lists/*

# UNVERIFIED: the arm64 zip layout and linkage are not checked yet.
# Upstream publishes no checksum for the release zip, so integrity relies on HTTPS and the pinned VERSION.
RUN echo "*** Installing Owncast ***" && \
  case "${TARGETARCH}" in \
    amd64) ARCH=64bit ;; \
    arm64) ARCH=arm64 ;; \
    *) echo "unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  curl -fsSL -o /tmp/owncast.zip \
    "https://github.com/owncast/owncast/releases/download/v${VERSION}/owncast-${VERSION}-linux-${ARCH}.zip" && \
  mkdir -p /tmp/owncast && \
  unzip -q /tmp/owncast.zip -d /tmp/owncast && \
  install -m 0755 /tmp/owncast/owncast /app/owncast && \
  echo "*** Installing license ***" && \
  mkdir -p /usr/share/licenses/owncast && \
  curl -fsSL -o /usr/share/licenses/owncast/LICENSE \
    "https://raw.githubusercontent.com/owncast/owncast/v${VERSION}/LICENSE" && \
  echo "*** Cleaning Up ***" && \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 8080 1935
VOLUME /config
WORKDIR /config
