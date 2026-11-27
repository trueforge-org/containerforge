FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG TARGETARCH
USER root

ENV HOME=/config

# Headless server archive from factorio.com, checked against the sha256 list the vendor publishes.
# Archives are not in the base image, so xz is already present (xz-utils in ubuntu base).
RUN echo "*** Installing Factorio headless ${VERSION} ***" && \
  set -eux; \
  case "${TARGETARCH}" in \
    amd64) platform="linux64"; file="factorio-headless_linux_${VERSION}.tar.xz" ;; \
    arm64) platform="linux-arm64"; file="factorio-headless_linux-arm64_${VERSION}.tar.xz" ;; \
    *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1 ;; \
  esac; \
  curl -fsSL --retry 8 -o "/tmp/${file}" "https://factorio.com/get-download/${VERSION}/headless/${platform}"; \
  curl -fsSL -o /tmp/sha256sums.txt "https://factorio.com/download/sha256sums/"; \
  (cd /tmp && grep " ${file}\$" sha256sums.txt | sha256sum -c -); \
  tar -xJf "/tmp/${file}" -C /app --strip-components=1; \
  if [ -d /app/bin/arm64 ] && [ ! -e /app/bin/x64 ]; then ln -s arm64 /app/bin/x64; fi; \
  chown -R apps:apps /app; chmod -R 755 /app; \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 34197/udp 27015/tcp

VOLUME /config
