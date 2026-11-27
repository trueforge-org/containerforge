
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG TARGETARCH
# UNVERIFIED: no upstream checksum asset. Fill in the self-computed sha256 of each tarball on the first download. Empty fails closed.
ARG SHA256_X86_64=
ARG SHA256_ARM64=
USER root

ENV \
  HOME=/config \
  XDG_CACHE_HOME=/tmp

RUN echo "*** Installing calibre ***" && \
  case "$TARGETARCH" in \
    amd64) CALIBRE_ARCH=x86_64; CALIBRE_SHA256="${SHA256_X86_64}" ;; \
    arm64) CALIBRE_ARCH=arm64; CALIBRE_SHA256="${SHA256_ARM64}" ;; \
    *) echo "unsupported arch: $TARGETARCH" && exit 1 ;; \
  esac && \
  curl -fsSL -o \
    /tmp/calibre.txz \
    "https://github.com/kovidgoyal/calibre/releases/download/v${VERSION}/calibre-${VERSION}-${CALIBRE_ARCH}.txz" && \
  echo "${CALIBRE_SHA256}  /tmp/calibre.txz" | sha256sum -c - && \
  mkdir -p /opt/calibre && \
  tar -xJf /tmp/calibre.txz -C /opt/calibre && \
  /opt/calibre/calibre_postinstall && \
  echo "*** Installing license ***" && \
  mkdir -p /usr/share/licenses/calibre && \
  cp /opt/calibre/LICENSE /usr/share/licenses/calibre/LICENSE && \
  echo "*** Cleaning Up ***" && \
  rm -f /tmp/calibre.txz

# UNVERIFIED: runtime apt libraries. Run ldd on /opt/calibre/calibre-server and /opt/calibre/ebook-convert, then install only what is missing, pinned to 26.04 versions.
# UNVERIFIED: whether calibre_postinstall is needed headless. The upstream linuxserver image runs it.

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config
