
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config

# UNVERIFIED: the release tarball layout (where sftpgo, templates, static and openapi sit) is not confirmed; inspect at build time.
# UNVERIFIED: no checksum asset is published on the release; this step cannot verify the download.
RUN echo "*** Installing SFTPGo ***" && \
  case "${TARGETARCH}" in amd64) ARCH=x86_64 ;; arm64) ARCH=arm64 ;; *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1 ;; esac && \
  mkdir -p /tmp/sftpgo-src && \
  curl -fL -o \
    /tmp/sftpgo.tar.xz \
    "https://github.com/drakkan/sftpgo/releases/download/v${VERSION}/sftpgo_v${VERSION}_linux_${ARCH}.tar.xz" && \
  tar -xJf /tmp/sftpgo.tar.xz -C /tmp/sftpgo-src && \
  install -D -m 0755 "$(find /tmp/sftpgo-src -type f -name sftpgo | head -n1)" /usr/local/bin/sftpgo && \
  mkdir -p /usr/share/sftpgo && \
  for d in templates static openapi; do \
    src="$(find /tmp/sftpgo-src -type d -name "$d" | head -n1)"; \
    cp -a "$src" /usr/share/sftpgo/; \
  done && \
  echo "*** Installing license ***" && \
  mkdir -p /usr/share/licenses/sftpgo && \
  curl -fL -o \
    /usr/share/licenses/sftpgo/LICENSE \
    "https://raw.githubusercontent.com/drakkan/sftpgo/v${VERSION}/LICENSE" && \
  echo "*** Cleaning Up ***" && \
  rm -rf /tmp/sftpgo.tar.xz /tmp/sftpgo-src

USER apps
COPY --chmod=0755 . /

EXPOSE 2022 8080

VOLUME /config
