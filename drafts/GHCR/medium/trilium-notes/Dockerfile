FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# set version label
ARG VERSION
ARG TARGETARCH
USER root

ENV \
  HOME=/config \
  TMPDIR=/tmp \
  TRILIUM_NETWORK_HOST=0.0.0.0 \
  TRILIUM_NETWORK_PORT=8080

RUN \
  echo "**** fetch trilium-notes ****" && \
  case "${TARGETARCH}" in \
    amd64) \
      TRILIUM_ARCH="linux-x64"; \
      TRILIUM_SHA256="a217b5ac702e4bd9d401cfd5c6e9ee25f0a6f4a0c67345c65bd67dc8663d3dce" ;; \
    arm64) \
      TRILIUM_ARCH="linux-arm64"; \
      TRILIUM_SHA256="5dd5a06d350f4f872ebec0b7170eaef489955f76ba62d99e93256978cc902281" ;; \
    *) \
      echo "unsupported arch: ${TARGETARCH}" && exit 1 ;; \
  esac && \
  curl -fL -o \
    /tmp/trilium.tar.xz \
    "https://github.com/TriliumNext/Trilium/releases/download/v${VERSION}/TriliumNotes-Server-v${VERSION}-${TRILIUM_ARCH}.tar.xz" && \
  echo "${TRILIUM_SHA256}  /tmp/trilium.tar.xz" | sha256sum -c - && \
  mkdir -p \
    /app && \
  # UNVERIFIED: --strip-components=1 assumes a single top-level directory in the tarball; check on first build.
  tar -xJf \
    /tmp/trilium.tar.xz -C \
    /app --strip-components=1 && \
  echo "**** install license ****" && \
  # UNVERIFIED: the tarball may not ship a LICENSE file; this is skipped when absent.
  if [ -f /app/LICENSE ]; then \
    install -D -m 0644 /app/LICENSE /usr/share/licenses/trilium-notes/LICENSE; \
  fi && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    $HOME/.cache && \
  rm -rf /var/lib/apt/lists/*

# copy local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 8080
VOLUME /config

WORKDIR /config
