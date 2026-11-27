FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS builder

ARG VERSION

ENV HOME=/tmp \
    CARGO_HOME=/tmp/cargo \
    RUSTUP_HOME=/tmp/rustup \
    CARGO_TARGET_DIR=/tmp/target \
    PATH=/tmp/cargo/bin:/usr/local/bin:/usr/bin:/bin

USER root

# UNVERIFIED: build dependency list is inferred from the upstream runtime libraries; confirm by building.
RUN \
  echo "**** install build deps ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    pkg-config \
    libssl-dev \
    libxml2-dev \
    nettle-dev && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# UNVERIFIED: rustup is fetched over HTTPS without a checksum.
# The toolchain is pinned to the version in upstream rust-toolchain.toml.
# UNVERIFIED: the trunk version is not pinned; take it from the upstream builder image (luigi311/tanoshi-builder).
RUN \
  echo "**** install rust toolchain ****" && \
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
    | sh -s -- -y --profile minimal --default-toolchain none && \
  rustup toolchain install 1.99.1 --profile minimal --target wasm32-unknown-unknown && \
  rustup default 1.99.1 && \
  cargo install trunk --locked

# The source is taken from the git tag; no release tarball or checksum exists for the server.
ADD https://github.com/luigi311/tanoshi.git#v${VERSION} /src

WORKDIR /src

RUN \
  echo "**** build web frontend ****" && \
  cd crates/tanoshi-web && \
  trunk build --release

RUN \
  echo "**** build server ****" && \
  cargo build -p tanoshi --release --locked

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION

ENV HOME=/config \
    TANOSHI_HOME=/config \
    TANOSHI_LOG=info \
    PORT=8080

USER root

# UNVERIFIED: runtime library names are taken from the upstream image; check the base first.
RUN \
  echo "**** install runtime deps ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    ca-certificates \
    libssl3 \
    libxml2-dev \
    libnettle8t64 && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

COPY --from=builder /tmp/target/release/tanoshi /app/tanoshi
COPY --from=builder /src/LICENSE /usr/share/licenses/tanoshi/LICENSE

RUN \
  chown -R root:root /app && \
  chmod 0755 /app/tanoshi

USER apps
COPY --chmod=0755 . /

WORKDIR /config
EXPOSE 8080
VOLUME /config
