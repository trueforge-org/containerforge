FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

# Paths are remapped to /config. Upstream uses /updater/data.
ENV HOME=/config \
    DATADIR=/config \
    CONFIG_FILEPATH=/config/config.json \
    BACKUP_DIRECTORY=/config

# Standalone binary per arch, verified against the checksums.txt asset of the v2.10.0 release (plan section 1).
RUN set -eux; \
  case "${TARGETARCH}" in \
    amd64) SHA256=868b9ab40374ea51d5caff09974414d2f9b5d5456e948f98391fdc3a15d51522 ;; \
    arm64) SHA256=d7b27ec100c5b04be0c24d9b6586a223991f2511a10561b3b0119557ecf53c84 ;; \
    *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1 ;; \
  esac; \
  mkdir -p /app /usr/share/licenses/ddns-updater; \
  curl -fsSL -o /app/ddns-updater \
    "https://github.com/qdm12/ddns-updater/releases/download/v${VERSION}/ddns-updater_${VERSION}_linux_${TARGETARCH}"; \
  echo "${SHA256}  /app/ddns-updater" | sha256sum -c -; \
  chmod 0755 /app/ddns-updater; \
  # UNVERIFIED: the LICENSE path at this tag. Confirm during the build.
  curl -fsSL -o /usr/share/licenses/ddns-updater/LICENSE \
    "https://raw.githubusercontent.com/qdm12/ddns-updater/v${VERSION}/LICENSE"; \
  chown -R apps:apps /app; \
  chmod -R 755 /app; \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 8000
VOLUME /config
