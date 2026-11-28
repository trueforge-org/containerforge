FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# set version label
ARG VERSION
ARG TARGETARCH
USER root

ENV HOME=/config

RUN \
  echo "**** install crane ****" && \
  case "${TARGETARCH}" in \
    amd64) GOARCH_ASSET=x86_64 ;; \
    arm64) GOARCH_ASSET=arm64 ;; \
    *) echo "unsupported arch: ${TARGETARCH}" && exit 1 ;; \
  esac && \
  base="https://github.com/google/go-containerregistry/releases/download/v${VERSION}" && \
  mkdir -p /tmp/crane && \
  curl -fsSL -o /tmp/crane.tar.gz \
    "${base}/go-containerregistry_Linux_${GOARCH_ASSET}.tar.gz" && \
  curl -fsSL -o /tmp/checksums.txt \
    "${base}/checksums.txt" && \
  cd /tmp && \
  grep -F "  go-containerregistry_Linux_${GOARCH_ASSET}.tar.gz" checksums.txt > /tmp/checksum-line.txt && \
  sha256sum -c /tmp/checksum-line.txt && \
  tar xzf /tmp/crane.tar.gz -C /tmp/crane && \
  install -m 0755 /tmp/crane/crane /usr/local/bin/crane && \
  mkdir -p /usr/share/licenses/crane && \
  cp /tmp/crane/LICENSE /usr/share/licenses/crane/ && \
  rm -rf /tmp/*
# UNVERIFIED: arm64 tarball layout (crane/LICENSE at archive root) is assumed, not inspected.

# add local files
USER apps
COPY --chmod=0755 . /

WORKDIR /config

VOLUME /config
