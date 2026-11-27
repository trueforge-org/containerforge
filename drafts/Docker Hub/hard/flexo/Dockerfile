FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS build

ARG VERSION
ARG SCRUFFY_VERSION
USER root
ENV CARGO_HOME=/tmp/cargo

# UNVERIFIED: the Ubuntu 26.04 rustc may be older than the Rust version upstream's latest commit expects
# (1.96). If it is, pin a toolchain by checksum instead of using apt.
RUN echo "*** Installing Rust toolchain and build dependencies ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    cargo \
    rustc \
    pkg-config \
    libssl-dev \
    libcurl4-openssl-dev \
    ca-certificates \
    curl \
    build-essential && \
  rm -rf /var/lib/apt/lists/*

# No checksum is published for source tags. flexo's Cargo.lock is committed, so --locked pins dependencies.
# The tag archive is the source of flexo, and flexo_purge_cache sits at the repository root.
# UNVERIFIED: the scruffy tarball URL and that its tree builds with --locked. Its Cargo.toml says 0.1.0 while the tag is 0.2.0.
RUN echo "*** Building flexo ${VERSION} ***" && \
  mkdir -p /src/flexo /src/scruffy && \
  curl -fsSL "https://github.com/nroi/flexo/archive/refs/tags/${VERSION}.tar.gz" | tar xz --strip-components=1 -C /src/flexo && \
  cd /src/flexo/flexo && \
  CARGO_TARGET_DIR=/tmp/target-flexo cargo build --release --locked && \
  echo "*** Building scruffy ${SCRUFFY_VERSION} (purges the package cache) ***" && \
  curl -fsSL "https://github.com/nroi/scruffy/archive/refs/tags/${SCRUFFY_VERSION}.tar.gz" | tar xz --strip-components=1 -C /src/scruffy && \
  cd /src/scruffy && \
  CARGO_TARGET_DIR=/tmp/target-scruffy cargo build --release --locked && \
  rm -rf /tmp/cargo

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

USER root

ENV HOME=/config

# UNVERIFIED: package names on Ubuntu 26.04. Only add what ldd reports missing for the built binaries.
RUN echo "*** Installing flexo runtime dependencies ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    libssl3t64 \
    libcurl4t64 && \
  rm -rf /var/lib/apt/lists/*

COPY --chmod=0755 --from=build /tmp/target-flexo/release/flexo /usr/bin/flexo
COPY --chmod=0755 --from=build /tmp/target-scruffy/release/scruffy /usr/bin/scruffy
COPY --chmod=0755 --from=build /src/flexo/flexo_purge_cache /usr/bin/flexo_purge_cache
COPY --from=build /src/flexo/LICENSE /usr/share/licenses/flexo/LICENSE
COPY --from=build /src/scruffy/LICENSE /usr/share/licenses/scruffy/LICENSE

USER apps
COPY --chmod=0755 . /
WORKDIR /config

EXPOSE 7878

VOLUME /config

CMD ["/start.sh"]
