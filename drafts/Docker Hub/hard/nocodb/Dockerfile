
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG TARGETARCH
ARG NOCO_SHA256_AMD64
ARG NOCO_SHA256_ARM64
USER root

# Caches and the packaged binary's scratch space go to /tmp; data goes to /config
ENV \
  HOME=/tmp/home \
  PORT=8080 \
  NC_APP_DATA_DIR=/config

# Only releases up to 2026.06.1 ship Noco-linux-* binaries (see plan section 1)
RUN echo "*** Installing NocoDB ***" && \
  case "${TARGETARCH}" in \
    amd64) NOCO_ARCH=x64; NOCO_SHA="${NOCO_SHA256_AMD64}" ;; \
    arm64) NOCO_ARCH=arm64; NOCO_SHA="${NOCO_SHA256_ARM64}" ;; \
    *) echo "unsupported arch ${TARGETARCH}" && exit 1 ;; \
  esac && \
  mkdir -p /app /usr/share/licenses/nocodb && \
  curl -fsSL -o \
    /app/Noco \
    "https://github.com/nocodb/nocodb/releases/download/${VERSION}/Noco-linux-${NOCO_ARCH}" && \
  echo "${NOCO_SHA}  /app/Noco" | sha256sum -c - && \
  chmod 0755 /app/Noco && \
  echo "*** Fetching license (UNVERIFIED: tag URL for 2026.06.1; fall back to develop) ***" && \
  curl -fsSL -o \
    /usr/share/licenses/nocodb/LICENSE.md \
    "https://raw.githubusercontent.com/nocodb/nocodb/${VERSION}/LICENSE.md" && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  mkdir -p /tmp/home

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config

WORKDIR /config
