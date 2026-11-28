FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# UNVERIFIED: zerotier-one needs /dev/net/tun and CAP_NET_ADMIN; rootless apps cannot run it (see plan section 9)
RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    zstd \
    zerotier-one && \
  echo "**** fetch ztncui-aio release ****" && \
  case "${TARGETARCH}" in \
    amd64) arch="x86_64" ;; \
    arm64) arch="aarch64" ;; \
    *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  mkdir -p /tmp/ztncui-stage /opt/key-networks/ztncui && \
  curl -fL -o \
    /tmp/ztncui-aio.tar.zst \
    "https://github.com/kmahyyg/ztncui-aio/releases/download/v${VERSION}/ztncui-aio-${arch}.tar.zst" && \
  zstd -d -c /tmp/ztncui-aio.tar.zst | tar -x -C /tmp/ztncui-stage && \
  # UNVERIFIED: tarball layout not inspected; assumes the archive root is the ztncui tree
  cp -a /tmp/ztncui-stage/. /opt/key-networks/ztncui/ && \
  echo "**** link state to config ****" && \
  rm -rf /var/lib/zerotier-one /etc/zt-mkworld /opt/key-networks/ztncui/etc && \
  ln -s /config/zerotier-one /var/lib/zerotier-one && \
  ln -s /config/zt-mkworld /etc/zt-mkworld && \
  ln -s /config/ztncui-etc /opt/key-networks/ztncui/etc && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    $HOME/.cache && \
  rm -rf /var/lib/apt/lists/*

# copy local files
USER apps
COPY --chmod=0755 . /

ENV HOME=/config \
    TMPDIR=/tmp

# ports and volumes
EXPOSE 3443
VOLUME /config

WORKDIR /config
