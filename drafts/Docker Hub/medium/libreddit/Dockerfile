
# BLOCKED (see plan.md section 10): upstream has had no release since 2023; confirm the product is worth shipping before merge
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH

USER root

# amd64: release binary verified against the published .sha256
# arm64: built from the tag with cargo
# UNVERIFIED: arm64 cargo and rustc versions from Ubuntu 26.04, and whether the tag ships Cargo.lock (--locked needs it)
# UNVERIFIED: the amd64 release asset is static (upstream builds a musl target); confirm with file/ldd
# UNVERIFIED: the LICENSE path at the tag
RUN echo "*** Installing libreddit ${VERSION} (${TARGETARCH}) ***" && \
  mkdir -p /app/libreddit && \
  case "${TARGETARCH}" in \
    amd64) \
      curl -fsSL -o /tmp/libreddit \
        "https://github.com/libreddit/libreddit/releases/download/${VERSION}/libreddit" && \
      curl -fsSL -o /tmp/libreddit.sha256 \
        "https://github.com/libreddit/libreddit/releases/download/${VERSION}/libreddit.sha256" && \
      (cd /tmp && sha256sum -c libreddit.sha256) && \
      install -m 0755 /tmp/libreddit /app/libreddit/libreddit ;; \
    arm64) \
      apt-get update && \
      apt-get install -y --no-install-recommends cargo rustc && \
      mkdir -p /tmp/src && \
      curl -fsSL "https://github.com/libreddit/libreddit/archive/refs/tags/${VERSION}.tar.gz" \
        | tar xz -C /tmp/src --strip-components=1 && \
      (cd /tmp/src && cargo build --release --locked) && \
      install -m 0755 /tmp/src/target/release/libreddit /app/libreddit/libreddit ;; \
    *) echo "unsupported arch: ${TARGETARCH}" && exit 1 ;; \
  esac && \
  install -d /usr/share/licenses/libreddit && \
  curl -fsSL -o /usr/share/licenses/libreddit/LICENSE \
    "https://raw.githubusercontent.com/libreddit/libreddit/${VERSION}/LICENSE" && \
  chown -R root:root /app && chmod -R 755 /app && \
  echo "*** Cleaning Up ***" && \
  rm -rf /tmp/* /var/lib/apt/lists/*

# run as 568
USER apps
COPY --chmod=0755 . /

EXPOSE 8080
WORKDIR /app/libreddit
