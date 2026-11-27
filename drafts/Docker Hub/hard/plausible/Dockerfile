# UNVERIFIED: an ubuntu (resolute) variant of this hexpm/elixir tag must exist.
# Fallback: install Erlang/Elixir with apt or asdf in an ubuntu stage.
FROM hexpm/elixir:1.20.4-erlang-28.5.0.5-ubuntu-resolute AS build

ARG VERSION

ENV \
  MIX_ENV=ce \
  NODE_ENV=production \
  HEX_HOME=/tmp/hex \
  MIX_HOME=/tmp/mix \
  npm_config_cache=/tmp/npm

USER root

RUN apt-get update && \
  apt-get install -y --no-install-recommends git build-essential python3 ca-certificates curl brotli && \
  rm -rf /var/lib/apt/lists/*

# UNVERIFIED: Node 24 per upstream Dockerfile. Copying binaries from a bookworm image may not match this glibc;
# installing Node in this stage is the alternative.
COPY --from=node:24.22.1-bookworm-slim@sha256:be8204d4bd327363357f532187b752ff62759c31bedf98e9e18fc08c9cbd605c /usr/local/bin/node /usr/local/bin/npm /usr/local/bin/npx /usr/local/bin/
COPY --from=node:24.22.1-bookworm-slim@sha256:be8204d4bd327363357f532187b752ff62759c31bedf98e9e18fc08c9cbd605c /usr/local/lib/node_modules /usr/local/lib/node_modules

RUN mkdir -p /src && \
  curl -fsSL "https://github.com/plausible/analytics/archive/refs/tags/v${VERSION}.tar.gz" | \
  tar xz -C /src --strip-components=1

WORKDIR /src

# Build steps follow the upstream Dockerfile at tag v${VERSION}; re-read it when bumping the version
RUN mix deps.get --only ce && \
  (cd assets && npm install) && \
  npm install --prefix ./tracker && \
  npm run deploy --prefix ./tracker && \
  mix assets.deploy && \
  mix phx.digest priv/static && \
  # UNVERIFIED: this step needs network at build time and may need a license acknowledgement
  mix download_country_database && \
  mix sentry.package_source_code && \
  mix release plausible --path /out

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

ARG VERSION

ENV \
  HOME=/config \
  LANG=C.UTF-8 \
  LISTEN_IP=0.0.0.0 \
  DEFAULT_DATA_DIR=/config/data \
  RELEASE_TMP=/tmp/release

USER root

# UNVERIFIED: package names on Ubuntu 26.04; check ldd on the release's erts binaries
RUN apt-get update && \
  apt-get install -y --no-install-recommends ca-certificates libncurses6 libssl3t64 libstdc++6 openssl && \
  rm -rf /var/lib/apt/lists/*

COPY --from=build /out /app

RUN echo "*** Installing licenses ***" && \
  install -d /usr/share/licenses/plausible && \
  cp /src/LICENSE.md /usr/share/licenses/plausible/ && \
  # UNVERIFIED: third-party notices shipped under /app/priv
  chown -R apps:apps /app && chmod -R 755 /app

USER apps
COPY --chmod=0755 . /

EXPOSE 8000

VOLUME /config
