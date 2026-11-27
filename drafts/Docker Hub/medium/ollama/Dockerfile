
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

ENV \
  OLLAMA_HOST=0.0.0.0:11434 \
  OLLAMA_MODELS=/config/models \
  HOME=/config \
  TMPDIR=/tmp

# Prebuilt binary with bundled libraries. The checksum comes from the upstream sha256sum.txt.
# UNVERIFIED: the tarball layout (bin/ and lib/ollama/) and the relative library lookup
RUN echo "*** Installing Ollama ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends zstd && \
  rm -rf /var/lib/apt/lists/* && \
  case "${TARGETARCH}" in \
    amd64) ollama_arch=amd64 ;; \
    arm64) ollama_arch=arm64 ;; \
    *) echo "unsupported ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  base="https://github.com/ollama/ollama/releases/download/v${VERSION}" && \
  curl -fL -o /tmp/sha256sum.txt "${base}/sha256sum.txt" && \
  curl -fL -o "/tmp/ollama-linux-${ollama_arch}.tar.zst" "${base}/ollama-linux-${ollama_arch}.tar.zst" && \
  (cd /tmp && grep " ollama-linux-${ollama_arch}.tar.zst\$" sha256sum.txt | sha256sum -c -) && \
  mkdir -p /app/ollama && \
  tar --zstd -xf "/tmp/ollama-linux-${ollama_arch}.tar.zst" -C /app/ollama && \
  rm -f /tmp/ollama-linux-*.tar.zst /tmp/sha256sum.txt && \
  chown -R root:root /app && chmod -R 755 /app

# UNVERIFIED: the LICENSE path in the upstream repo at this tag
RUN mkdir -p /usr/share/licenses/ollama \
  && curl -fsSL -o /usr/share/licenses/ollama/LICENSE \
    "https://raw.githubusercontent.com/ollama/ollama/v${VERSION}/LICENSE"

USER apps
COPY --chmod=0755 . /

EXPOSE 11434

VOLUME /config
