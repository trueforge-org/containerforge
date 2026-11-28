FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
ARG CHANNEL=stable
# UNVERIFIED: upstream publishes no checksum. These pins must be computed from the vendor .deb and filled in before merge.
# The build fails while they are empty.
ARG DECONZ_SHA256_AMD64=""
ARG DECONZ_SHA256_ARM64=""
USER root

ENV \
  HOME=/config \
  DECONZ_APPDATA_DIR=/config \
  DECONZ_WEB_PORT=8080 \
  DECONZ_WS_PORT=8443 \
  DECONZ_UPNP=0

# Vendor .deb installed with apt so apt resolves the Qt5 dependencies.
# UNVERIFIED: the .deb is downloaded over plain HTTP; the sha256 pin is the only integrity check.
# UNVERIFIED: the binary path /usr/bin/deCONZ is assumed; no license file is shipped yet.
RUN set -eu; \
  case "$TARGETARCH" in \
    amd64) deb_url="http://deconz.dresden-elektronik.de/ubuntu/${CHANNEL}/deconz-${VERSION}-qt5.deb"; deb_sha="${DECONZ_SHA256_AMD64}" ;; \
    arm64) deb_url="http://deconz.dresden-elektronik.de/debian/${CHANNEL}/deconz_${VERSION}-debian-buster-${CHANNEL}_arm64.deb"; deb_sha="${DECONZ_SHA256_ARM64}" ;; \
    *) echo "unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
  esac; \
  if [ -z "${deb_sha}" ]; then echo "sha256 pin for ${TARGETARCH} is not set" >&2; exit 1; fi; \
  echo "*** Installing deCONZ ${VERSION} ***"; \
  apt-get update; \
  apt-get install -y --no-install-recommends curl ca-certificates; \
  curl -fL -o /tmp/deconz.deb "${deb_url}"; \
  echo "${deb_sha}  /tmp/deconz.deb" | sha256sum -c -; \
  apt-get install -y --no-install-recommends /tmp/deconz.deb; \
  rm -f /tmp/deconz.deb; \
  mkdir -p /config; \
  chown apps:apps /config; \
  rm -rf /var/lib/apt/lists/*

USER apps
COPY --chmod=0755 . /

EXPOSE 8080
EXPOSE 8443

VOLUME /config
