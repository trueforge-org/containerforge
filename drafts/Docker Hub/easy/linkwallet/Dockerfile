
# UNVERIFIED base digest: the repo's trueforge ubuntu digest (shared with the other apps) is used here
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config

# The release ships its own checksum file, which is verified here, so no hashes are pinned in this file.
RUN set -eux; \
  echo "*** Installing linkwallet ***"; \
  case "${TARGETARCH}" in amd64) arch=x86_64 ;; arm64) arch=arm64 ;; *) echo "unsupported arch ${TARGETARCH}"; exit 1 ;; esac; \
  base="https://github.com/tardisx/linkwallet/releases/download/v${VERSION}"; \
  tgz="linkwallet_Linux_${arch}.tar.gz"; \
  curl -fsSL -o "/tmp/${tgz}" "${base}/${tgz}"; \
  curl -fsSL -o /tmp/checksums.txt "${base}/linkwallet_${VERSION}_checksums.txt"; \
  (cd /tmp && grep " ${tgz}\$" checksums.txt | sha256sum -c -); \
  mkdir -p /tmp/lw /app /usr/share/licenses/linkwallet; \
  tar xzf "/tmp/${tgz}" -C /tmp/lw; \
  install -m 0755 /tmp/lw/linkwallet /app/linkwallet; \
  install -m 0644 /tmp/lw/LICENSE /usr/share/licenses/linkwallet/LICENSE; \
  chown -R apps:apps /app; \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config
WORKDIR /config
