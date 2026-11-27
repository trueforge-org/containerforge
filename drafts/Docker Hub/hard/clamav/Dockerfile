
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
# UNVERIFIED: clamav.net publishes no sha256 for the .deb files, only detached .sig files.
# Verify the .sig with the ClamAV PGP key, then fill these in. The build fails closed while they are empty.
ARG CLAMAV_SHA256_AMD64=""
ARG CLAMAV_SHA256_ARM64=""
USER root

ENV \
  HOME=/config \
  TMPDIR=/tmp

# UNVERIFIED: which runtime libraries the vendor .deb needs (apt resolves them, check with dpkg -I)
RUN echo "*** Installing ClamAV ***" && \
  case "${TARGETARCH}" in \
    amd64) DEB_ARCH=x86_64; SHA="${CLAMAV_SHA256_AMD64}" ;; \
    arm64) DEB_ARCH=aarch64; SHA="${CLAMAV_SHA256_ARM64}" ;; \
    *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  curl -fsSL -o /tmp/clamav.deb \
    "https://github.com/Cisco-Talos/clamav/releases/download/clamav-${VERSION}/clamav-${VERSION}.linux.${DEB_ARCH}.deb" && \
  echo "${SHA}  /tmp/clamav.deb" | sha256sum -c - && \
  apt-get update && \
  apt-get install -y --no-install-recommends /tmp/clamav.deb && \
  echo "*** Installing license ***" && \
  mkdir -p /usr/share/licenses/clamav && \
  curl -fsSL -o /usr/share/licenses/clamav/COPYING.txt \
    "https://raw.githubusercontent.com/Cisco-Talos/clamav/clamav-${VERSION}/COPYING.txt" && \
  echo "*** Cleaning Up ***" && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 3310

VOLUME /config

CMD ["/start.sh"]
