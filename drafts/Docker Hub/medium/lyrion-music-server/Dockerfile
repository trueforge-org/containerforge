FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV HOME=/config \
    DEBIAN_FRONTEND=noninteractive \
    LC_ALL=C.UTF-8 \
    TMPDIR=/tmp

# UNVERIFIED: the .deb URL pattern is confirmed for 9.1.1 only. Confirm it for VERSION before the first build.
# UNVERIFIED: no vendor checksum yet. Add a sha256 check against a published value before the PR.
# Only amd64 is verified. No arm64 .deb is listed upstream.
RUN \
  echo "**** install lyrion music server ${VERSION} ****" && \
  case "${TARGETARCH}" in \
    amd64) deb_arch=amd64 ;; \
    *) echo "unsupported arch ${TARGETARCH}: no verified .deb" >&2; exit 1 ;; \
  esac && \
  curl -fsSL -o /tmp/lms.deb \
    "https://downloads.lms-community.org/LyrionMusicServer_v${VERSION}/lyrionmusicserver_${VERSION}_${deb_arch}.deb" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    lame \
    opus-tools \
    libgomp1 \
    libatomic1 \
    /tmp/lms.deb

# UNVERIFIED: the .deb's install tree, found by the slimserver.pl entry script. The package's postinst may try to
# create a service user or start a service. Check both in the first build, and do not run them in the image.
RUN \
  echo "**** copy install tree to /app ****" && \
  install_dir="$(dirname "$(dpkg -L lyrionmusicserver | grep -m1 '/slimserver\.pl$')")" && \
  echo "lms tree: ${install_dir}" && \
  mkdir -p /app/lyrion-music-server /config && \
  cp -a "${install_dir}/." /app/lyrion-music-server/ && \
  mkdir -p /usr/share/licenses/lyrion-music-server && \
  cp /usr/share/doc/lyrionmusicserver/copyright /usr/share/licenses/lyrion-music-server/copyright && \
  echo "**** cleanup ****" && \
  chown apps:apps /config && \
  chown -R root:root /app && \
  chmod -R 755 /app && \
  rm -rf /var/lib/apt/lists/* /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 3483/tcp 3483/udp 9000/tcp 9090/tcp

VOLUME /config

WORKDIR /config
