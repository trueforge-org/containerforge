FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config \
  SHIORI_DIR=/config \
  SHIORI_HTTP_PORT=8080

RUN echo "*** Installing Shiori ***" && \
  case "${TARGETARCH}" in \
    amd64) ARCH="x86_64" ;; \
    arm64) ARCH="aarch64" ;; \
    *) echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  FILE="shiori_Linux_${ARCH}_${VERSION}.tar.gz" && \
  mkdir -p /tmp/shiori /app /usr/share/licenses/shiori && \
  curl -fL -o "/tmp/${FILE}" \
    "https://github.com/go-shiori/shiori/releases/download/v${VERSION}/${FILE}" && \
  curl -fL -o /tmp/checksums.txt \
    "https://github.com/go-shiori/shiori/releases/download/v${VERSION}/checksums.txt" && \
  echo "*** Verifying checksum ***" && \
  (cd /tmp && grep " ${FILE}\$" checksums.txt | sha256sum -c -) && \
  tar xzf "/tmp/${FILE}" -C /tmp/shiori && \
  install -m 0755 /tmp/shiori/shiori /app/shiori && \
  install -m 0644 /tmp/shiori/LICENSE /usr/share/licenses/shiori/LICENSE && \
  chown -R apps:apps /app && \
  chmod -R 755 /app && \
  echo "*** Cleaning Up ***" && \
  rm -rf /tmp/shiori "/tmp/${FILE}" /tmp/checksums.txt

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config
