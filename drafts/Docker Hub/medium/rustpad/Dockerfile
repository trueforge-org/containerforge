FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454 AS buildstage

ARG VERSION
ARG GITHUB_SHA=unknown
USER root

# Keep every build cache in /tmp (build stage only, never in the final image).
ENV \
  CARGO_HOME=/tmp/cargo \
  RUSTUP_HOME=/tmp/rustup \
  CARGO_TARGET_DIR=/tmp/target \
  npm_config_cache=/tmp/npm \
  PATH=/tmp/cargo/bin:$PATH

# UNVERIFIED: apt versions of rustup, nodejs and npm on ubuntu 26.04 against Cargo.lock and package.json engines
# UNVERIFIED: wasm-pack is installed unpinned here. Pin the version once it is chosen.
RUN echo "*** Installing build packages ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    pkg-config \
    libssl-dev \
    ca-certificates \
    curl \
    nodejs \
    npm \
    rustup && \
  rustup default stable && \
  rustup target add wasm32-unknown-unknown && \
  cargo install wasm-pack --locked

RUN echo "*** Fetching rustpad ${VERSION} ***" && \
  mkdir -p /tmp/src && \
  curl -fL -o \
    /tmp/rustpad.tar.gz \
    "https://github.com/ekzhang/rustpad/archive/${VERSION}.tar.gz" && \
  tar xzf \
    /tmp/rustpad.tar.gz -C \
    /tmp/src --strip-components=1 && \
  rm /tmp/rustpad.tar.gz

# Frontend and wasm package. Output is architecture-neutral.
RUN echo "*** Building wasm and frontend ***" && \
  cd /tmp/src && \
  wasm-pack build rustpad-wasm && \
  npm ci && \
  VITE_SHA="${GITHUB_SHA}" npm run check && \
  VITE_SHA="${GITHUB_SHA}" npm run build

# UNVERIFIED: package name `rustpad-server` from the workspace Cargo.toml
RUN echo "*** Building rustpad-server ***" && \
  cd /tmp/src && \
  cargo build --release -p rustpad-server && \
  rm -rf /tmp/cargo/registry /tmp/rustup /tmp/npm /tmp/src/node_modules

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION
USER root

# UNVERIFIED: runtime shared libraries (check with ldd on rustpad-server, libssl may be needed)
# The server serves dist/ relative to its working directory (UNVERIFIED in rustpad-server/src/lib.rs)
RUN mkdir -p \
    /app/rustpad \
    /usr/share/licenses/rustpad && \
  chown -R root:root /app/rustpad && \
  chmod -R 755 /app/rustpad

COPY --from=buildstage /tmp/src/dist /app/rustpad/dist
COPY --from=buildstage /tmp/target/release/rustpad-server /app/rustpad/rustpad-server
COPY --from=buildstage /tmp/src/LICENSE /usr/share/licenses/rustpad/LICENSE

ENV \
  PORT=3030 \
  EXPIRY_DAYS=1 \
  RUST_LOG=info

USER apps
COPY --chmod=0755 . /

EXPOSE 3030

VOLUME /config

WORKDIR /app/rustpad
