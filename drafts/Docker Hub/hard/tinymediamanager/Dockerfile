
# UNVERIFIED digest: the kasmvnc 1.5.2 digest is not read for this app. The obs-ndi plan lists one for the same tag, check it before pinning.
FROM ghcr.io/trueforge-org/kasmvnc:1.5.2

ARG VERSION
ARG TARGETARCH
USER root

# UNVERIFIED: package name on ubuntu 26.04 (check with apt-cache policy libmediainfo0v5)
RUN echo "*** Installing libmediainfo ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends libmediainfo0v5 && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/*

# The checksum comes from the upstream .sha256 file next to each tarball, so it stays in step with VERSION
RUN echo "*** Installing tinyMediaManager ${VERSION} ***" && \
  case "${TARGETARCH}" in amd64|arm64) ;; *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1 ;; esac && \
  URL="https://archive.tinymediamanager.org/v${VERSION}/tinyMediaManager-${VERSION}-linux-${TARGETARCH}.tar.xz" && \
  curl -fsSL -o /tmp/tmm.tar.xz "${URL}" && \
  SHA="$(curl -fsSL "${URL}.sha256")" && \
  echo "${SHA}  /tmp/tmm.tar.xz" | sha256sum -c - && \
  mkdir -p /app /usr/share/licenses/tinymediamanager && \
  tar -xJf /tmp/tmm.tar.xz -C /app && \
  cp /app/tinyMediaManager/LICENSE /usr/share/licenses/tinymediamanager/LICENSE && \
  rm -f /app/tinyMediaManager/.userdir && \
  printf '%s\n' '-Dtmm.contentfolder=/config/data' '-Dtmm.noupdate=true' > /app/tinyMediaManager/extra.txt && \
  chmod -R a+rX /app && \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 3000 3001

VOLUME /config

WORKDIR /config
