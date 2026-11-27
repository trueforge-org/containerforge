FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG RTORRENT_VERSION
ARG TARGETARCH
USER root

ENV HOME=/tmp

# Only amd64: the flood asset URL below is flood-linux-x64. No arm64 asset is confirmed.
# UNVERIFIED: the Ubuntu 26.04 rtorrent package version. Pin RTORRENT_VERSION to match it, or build from source in a separate stage.
RUN echo "*** Installing rtorrent ***" && \
  [ "${TARGETARCH}" = "amd64" ] || { echo "unsupported arch ${TARGETARCH}"; exit 1; } && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    rtorrent=${RTORRENT_VERSION}* \
    mediainfo && \
  rm -rf /var/lib/apt/lists/*
# nginx is dropped unless flood needs it (UNVERIFIED).

# UNVERIFIED: no checksum is published for the flood binary. Pin a SHA256 computed from the release once known.
RUN echo "*** Installing flood ${VERSION} ***" && \
  mkdir -p /app && \
  curl -fsSL -o /app/flood \
    "https://github.com/jesec/flood/releases/download/v${VERSION}/flood-linux-x64" && \
  chmod 0755 /app/flood
# UNVERIFIED: flood and rtorrent license texts are not yet read, so no license file is shipped.

USER apps
COPY --chmod=0755 . /

EXPOSE 3000

VOLUME /config
