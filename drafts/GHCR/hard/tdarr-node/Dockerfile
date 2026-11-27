# UNVERIFIED (initial draft): DATE, the build suffix of the node zip, is not resolved yet, so the
# download fails until DATE is set in docker-bake.hcl. ffmpeg comes from the upstream tdarr_acc base in
# the upstream image, and its apt package is unverified here.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG DATE
ARG TARGETARCH
USER root

ENV HOME=/config \
    inContainer=true

RUN \
  echo "*** Installing runtime dependencies ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    ffmpeg \
    libtesseract-dev \
    mkvtoolnix \
    unzip && \
  rm -rf /var/lib/apt/lists/*

# UNVERIFIED: no checksum is published upstream. Record the SHA-256 of the zip once the build is confirmed.
RUN \
  echo "*** Installing Tdarr Node ${VERSION} ***" && \
  case "${TARGETARCH}" in \
    amd64) TDARR_ARCH=linux_x64 ;; \
    arm64) TDARR_ARCH=linux_arm64 ;; \
    *) echo "tdarr-node: unsupported architecture ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  curl -fL -o /tmp/Tdarr_Node.zip \
    "https://tdarrs.s3.us-west-000.backblazeb2.com/dev/versions/${VERSION}/${TDARR_ARCH}/Tdarr_Node_${DATE}.zip" && \
  mkdir -p /app/tdarr-node && \
  unzip -q /tmp/Tdarr_Node.zip -d /app/tdarr-node -x '*.exe' && \
  rm -f /tmp/Tdarr_Node.zip

# Node state goes to /config and the transcode cache to /temp, both writable by apps.
# /app stays read-only at runtime, so the node's folders are symlinks into /config.
RUN \
  echo "*** Setting up writable paths ***" && \
  mkdir -p /config /temp && \
  ln -s /config/configs /app/tdarr-node/configs && \
  ln -s /config/logs /app/tdarr-node/logs && \
  chown -R apps:apps /config /temp

USER apps
COPY --chmod=0755 . /

VOLUME /config
VOLUME /temp
