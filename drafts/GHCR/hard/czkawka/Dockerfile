FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# set version label
ARG VERSION
ARG TARGETARCH
# GitHub release asset digests (sha256), not upstream-signed; re-verify with sha256sum before merge
ARG SHA256_AMD64=b62cf139ba6e0331e4a279d75d0caf5bfa81f16c645fdf0008dc7a830573e05f
ARG SHA256_ARM64=6ca6ec65029c3d5ed87ade0690508fcf9566f0bdbb1b480a773499a3a5041022
USER root

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    ca-certificates && \
  echo "**** fetch czkawka cli ****" && \
  case "${TARGETARCH}" in \
    amd64) asset="linux_czkawka_cli_heif_raw_avif_x86_64"; sha="${SHA256_AMD64}" ;; \
    arm64) asset="linux_czkawka_cli_heif_raw_avif_arm64"; sha="${SHA256_ARM64}" ;; \
    *) echo "unsupported arch ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  curl -fL -o \
    /tmp/czkawka_cli \
    "https://github.com/qarmin/czkawka/releases/download/${VERSION}/${asset}" && \
  echo "${sha}  /tmp/czkawka_cli" | sha256sum -c - && \
  mkdir -p /app/czkawka && \
  install -m 0755 /tmp/czkawka_cli /app/czkawka/czkawka_cli && \
  ln -sf /app/czkawka/czkawka_cli /usr/bin/czkawka_cli && \
  echo "**** fetch license ****" && \
  install -d /usr/share/licenses/czkawka && \
  curl -fL -o \
    /usr/share/licenses/czkawka/LICENSE \
    "https://raw.githubusercontent.com/qarmin/czkawka/${VERSION}/LICENSE_MIT_EVERYTHING_OUTSIDE_ANY_CARGO_APP_LIBRARY" && \
  echo "**** cleanup ****" && \
  chown -R apps:apps /app/czkawka && \
  chmod -R 755 /app/czkawka && \
  rm -rf \
    /tmp/* \
    $HOME/.cache && \
  rm -rf /var/lib/apt/lists/*

# UNVERIFIED: ldd on the binary is not run yet; add apt libraries only if it reports missing ones
ENV HOME=/config \
    XDG_CACHE_HOME=/tmp/.cache

# copy local files
USER apps
COPY --chmod=0755 . /

VOLUME /config /storage
WORKDIR /config
