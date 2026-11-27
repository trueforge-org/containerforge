FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH

# Release zip checksums (GitHub asset digests, 2026-11-25). Renovate does not update these:
# change them together with every VERSION bump.
# UNVERIFIED: the arm64 value was read from the release page and was not downloaded.
ARG SHA256_AMD64=51dbf724c94f8afa0b40fb1ef63a1fe418e7996e7b9536e1f0a5da695b8e18ef
ARG SHA256_ARM64=9f82cfb96fc48ac9bdfb94584dc6ba4648de1ac4fcd1276d2dd5a7e0f80398f7

USER root

ENV \
  HOME=/config \
  GOKAPI_CONFIG_DIR=/config/config \
  GOKAPI_DATA_DIR=/config/data

RUN set -eux; \
    case "${TARGETARCH}" in \
      amd64) SHA="${SHA256_AMD64}" ;; \
      arm64) SHA="${SHA256_ARM64}" ;; \
      *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    curl -fsSL -o /tmp/gokapi.zip "https://github.com/Forceu/Gokapi/releases/download/v${VERSION}/gokapi-${VERSION}_linux-${TARGETARCH}.zip"; \
    echo "${SHA}  /tmp/gokapi.zip" | sha256sum -c -; \
    unzip -q /tmp/gokapi.zip gokapi -d /app/; \
    mkdir -p /usr/share/licenses/gokapi; \
    curl -fsSL -o /usr/share/licenses/gokapi/LICENSE.md "https://raw.githubusercontent.com/Forceu/Gokapi/v${VERSION}/LICENSE.md"; \
    chown -R apps:apps /app; \
    chmod -R 755 /app; \
    rm -f /tmp/gokapi.zip

USER apps
COPY --chmod=0755 . /

EXPOSE 53842

VOLUME /config

WORKDIR /config
