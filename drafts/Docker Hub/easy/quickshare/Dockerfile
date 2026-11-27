FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
ARG TARGETARCH
# Release asset digests (GitHub API). Must be bumped together with VERSION.
ARG SHA256_AMD64=36256309c20e5494bafc499f5b9288c41c3d12ac63c4ffced25aae6754ae4ce0
ARG SHA256_ARM64=b8434a01bba52feeed64d462a1d2ce110aa36aa7b020376ad0df37718230e7e7
USER root

ENV \
  HOME=/config

RUN echo "*** Installing quickshare ***" && \
  case "${TARGETARCH}" in \
    amd64) SHA256="${SHA256_AMD64}" ;; \
    arm64) SHA256="${SHA256_ARM64}" ;; \
    *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  mkdir -p /app /usr/share/licenses/quickshare && \
  curl -fsSL -o \
    /tmp/qs.zip \
    "https://github.com/ihexxa/quickshare/releases/download/v${VERSION#v}/quickshare_linux_${TARGETARCH}.zip" && \
  echo "${SHA256}  /tmp/qs.zip" | sha256sum -c - && \
  unzip -j /tmp/qs.zip 'dist/*/quickshare' -d /app && \
  chmod 0755 /app/quickshare && \
  curl -fsSL -o \
    /usr/share/licenses/quickshare/LICENSE \
    "https://raw.githubusercontent.com/ihexxa/quickshare/v${VERSION#v}/LICENSE" && \
  chown -R root:root /app && \
  echo "*** Cleaning Up ***" && \
  rm -rf /tmp/*

USER apps
COPY --chmod=0755 . /

EXPOSE 8686

WORKDIR /config
VOLUME /config
