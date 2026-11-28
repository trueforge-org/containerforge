
# Legacy Firezone 0.7.x omnibus release. The WireGuard/nftables data plane needs root and NET_ADMIN, which
# this rootless image does not have (see plan.md section 10): only the portal can run unprivileged.
ARG ELIXIR_VERSION=1.14.3
ARG OTP_VERSION=25.2.1
# glibc builder (the upstream firezone/elixir builder is alpine/musl and would not run on the ubuntu runtime).
# Tag and digest read from Docker Hub on 2026-11-28; amd64 and arm64 are published.
ARG BUILDER_IMAGE=hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-ubuntu-jammy-20260509@sha256:a4ccc904c4e2aeb974a912e8306644c4d43a1d761fb5fbef237b8e9ce7bb51ca

# Node 18.16.0 (.tool-versions of the 0.7.36 tag) and yarn 1.x, taken from the official node image.
FROM docker.io/library/node:18.16.1-bullseye-slim@sha256:1ba1ddfc61b385b6436fd0fa0d1d42d322a0cd03c1ff110fa39e828511152aef AS node

FROM ${BUILDER_IMAGE} AS builder

ARG VERSION
ENV MIX_ENV=prod \
    HEX_HOME=/tmp/hex \
    MIX_HOME=/tmp/mix \
    VERSION=${VERSION}

WORKDIR /src

COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=node /opt /opt
RUN \
  ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm && \
  ln -s /opt/yarn-v1.22.19/bin/yarn /usr/local/bin/yarn && \
  echo "**** install build tools ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    python3 && \
  rm -rf /var/lib/apt/lists/*

RUN \
  echo "**** fetch firezone ${VERSION} ****" && \
  curl -fL "https://github.com/firezone/firezone/archive/refs/tags/${VERSION}.tar.gz" -o /tmp/firezone.tar.gz && \
  tar xzf /tmp/firezone.tar.gz --strip-components=1 -C /src && \
  rm -f /tmp/firezone.tar.gz

RUN \
  echo "**** build release ****" && \
  mix local.hex --force && \
  mix local.rebar --force && \
  mix deps.get --only prod && \
  mkdir -p config && \
  mix deps.compile && \
  cd apps/fz_http/assets && \
  yarn install --frozen-lockfile && \
  yarn deploy && \
  cd .. && \
  mix phx.digest && \
  cd /src && \
  mix compile && \
  mix release

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    iproute2 \
    libncurses6 \
    libstdc++6 \
    nftables \
    openssl && \
  mkdir -p /usr/share/licenses/firezone && \
  rm -rf /var/lib/apt/lists/*

# release from the builder stage, read-only at runtime
COPY --from=builder /src/_build/prod/rel/firezone /app
COPY --from=builder /src/LICENSE /usr/share/licenses/firezone/LICENSE

USER apps
ENV HOME=/config \
    TMPDIR=/tmp \
    RELEASE_TMP=/tmp/release \
    RELEASE_DISTRIBUTION=none \
    ERL_CRASH_DUMP=/tmp/erl_crash.dump \
    PHOENIX_HTTP_PORT=13000

# copy local files
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 13000
EXPOSE 51820/udp
VOLUME /config

WORKDIR /app
