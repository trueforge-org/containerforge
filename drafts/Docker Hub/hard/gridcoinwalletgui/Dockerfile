# UNVERIFIED: no digest is pinned yet. ghcr.io/trueforge-org/kasmvnc is not consumed by any app,
# so add the published digest once the kasmvnc image exists. The tag matches apps/kasmvnc/docker-bake.hcl.
FROM ghcr.io/trueforge-org/kasmvnc:1.5.2@sha256:7e96ef6465ad32c153f71fdff80fa4e2cb8fdfce1ab79dd269f08c7647505275

ARG VERSION
ARG TARGETARCH
USER root

ENV HOME=/config

# Checksums are the GitHub release asset digests recorded at planning time.
# UNVERIFIED: the amd64 tarball layout and whether it ships the Qt wallet. If it ships only the daemon,
# use the trixie amd64 .deb instead (sha256 008dac730c8f25e2a6b1feb291c196bcaa41a8a4a39bd6cfb981102916245be4).
RUN echo "*** Installing Gridcoin Research ${VERSION} ***" && \
  case "${TARGETARCH}" in \
    amd64) \
      curl -fsSL -o /tmp/gridcoin.tar.gz \
        "https://github.com/gridcoin-community/Gridcoin-Research/releases/download/${VERSION}/gridcoinresearch-${VERSION}-x86_64.tar.gz" && \
      echo "30d3e1755f99dbad3330e8858f44a0edf47596c6cf7ea34d96c52bf1d149dae5  /tmp/gridcoin.tar.gz" | sha256sum -c - && \
      mkdir -p /app/gridcoin && \
      tar -xzf /tmp/gridcoin.tar.gz -C /app/gridcoin ;; \
    arm64) \
      curl -fsSL -o /tmp/gridcoin.deb \
        "https://github.com/gridcoin-community/Gridcoin-Research/releases/download/${VERSION}/gridcoinresearch-qt_${VERSION}.trixie-1_arm64.deb" && \
      echo "ec0c24a8dc4a6350b084a34ead2e181617869db5d6c1ce979f10011ba934af0b  /tmp/gridcoin.deb" | sha256sum -c - && \
      mkdir -p /app/gridcoin && \
      dpkg-deb -x /tmp/gridcoin.deb /app/gridcoin ;; \
    *) \
      echo "Unsupported architecture: ${TARGETARCH}" >&2 && exit 1 ;; \
  esac && \
  # UNVERIFIED: the Qt library set for Ubuntu 26.04 (ldd on the binary). Trixie builds may not match.
  # The wallet binary path is /app/gridcoin/usr/bin/gridcoinresearch-qt for the .deb layout.
  echo "*** Installing licenses ***" && \
  mkdir -p /usr/share/licenses/gridcoinwalletgui && \
  curl -fsSL -o /usr/share/licenses/gridcoinwalletgui/COPYING \
    "https://raw.githubusercontent.com/gridcoin-community/Gridcoin-Research/${VERSION}/COPYING" && \
  echo "*** Cleaning Up ***" && \
  rm -rf /tmp/* && \
  chmod -R 755 /app && \
  # The kasmvnc base start.sh is kept as /kasmvnc-start.sh. The local start.sh wraps it.
  mv /start.sh /kasmvnc-start.sh

USER apps
COPY --chmod=0755 . /

EXPOSE 3000 3001

VOLUME /config
