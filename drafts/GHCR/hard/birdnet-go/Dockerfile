FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
# SHA256 of the release tarballs for VERSION, from the release checksums.txt (values read in the plan run).
ARG BIRDNET_SHA256_AMD64="c69a805ea92b359a1565deb05fc6b4cf97f72af71d87eb359a786ae5cb444bda"
ARG BIRDNET_SHA256_ARM64="8a325fc1133804583d9c0f235cfd3b3d055b8558440c69268afde8d8ab85b132"
USER root

ENV \
  HOME=/config \
  TZ=Etc/UTC \
  BIRDNET_MODELPATH=/app/birdnet-go/models

# UNVERIFIED: libasound2t64 name on ubuntu 26.04, and whether the base already has tzdata.
# UNVERIFIED: tarball layout (--strip-components=1) and whether it bundles the ONNX/TFLite runtime libraries.
RUN set -eu; \
  case "$TARGETARCH" in \
    amd64) birdnet_sha="${BIRDNET_SHA256_AMD64}" ;; \
    arm64) birdnet_sha="${BIRDNET_SHA256_ARM64}" ;; \
    *) echo "unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
  esac; \
  echo "*** Installing birdnet-go ${VERSION} ***"; \
  apt-get update; \
  apt-get install -y --no-install-recommends \
    ffmpeg \
    jq \
    libasound2t64 \
    procps \
    tzdata; \
  rm -rf /var/lib/apt/lists/*; \
  curl -fL -o /tmp/birdnet-go.tar.gz \
    "https://github.com/tphakala/birdnet-go/releases/download/${VERSION}/birdnet-go-linux-${TARGETARCH}-${VERSION}.tar.gz"; \
  echo "${birdnet_sha}  /tmp/birdnet-go.tar.gz" | sha256sum -c -; \
  mkdir -p /app/birdnet-go; \
  tar -xzf /tmp/birdnet-go.tar.gz -C /app/birdnet-go --strip-components=1; \
  rm -f /tmp/birdnet-go.tar.gz; \
  curl -fL -o /tmp/birdnet-go.LICENSE "https://raw.githubusercontent.com/tphakala/birdnet-go/${VERSION}/LICENSE"; \
  install -D -m0644 /tmp/birdnet-go.LICENSE /usr/share/licenses/birdnet-go/LICENSE; \
  rm -f /tmp/birdnet-go.LICENSE; \
  mkdir -p /config /data/clips; \
  chown apps:apps /config /data /data/clips

USER apps
COPY --chmod=0755 . /

EXPOSE 8080

VOLUME /config
VOLUME /data
WORKDIR /config
