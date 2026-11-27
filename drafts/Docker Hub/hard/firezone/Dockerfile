
# BLOCKED draft: upstream 0.7.36 needs root and NET_ADMIN for WireGuard, see plan.md section 10.

# renovate-tracked via docker-bake.hcl VERSION
ARG ELIXIR_VERSION=1.14.3
ARG OTP_VERSION=25.2.1
# UNVERIFIED: glibc (ubuntu) builder tag. The upstream firezone/elixir builder is alpine (musl),
# which would not run on the ubuntu runtime. Confirm the tag on Docker Hub (hexpm/elixir).
ARG BUILDER_IMAGE=hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-ubuntu-jammy-UNVERIFIED

FROM ${BUILDER_IMAGE} AS builder

ARG VERSION
ENV MIX_ENV=prod \
    HEX_HOME=/tmp/hex \
    MIX_HOME=/tmp/mix \
    VERSION=${VERSION}

WORKDIR /src

# UNVERIFIED: upstream pins Node 18.16.0 via .tool-versions, apt nodejs may differ
RUN \
  echo "**** install build tools ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    nodejs \
    npm \
    python3 && \
  npm install -g yarn && \
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

FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:19cb2ceefb7364eed299290b4f4270d50a2eaa9393b0002b267f5b4f13926454

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

# upstream bootstrap writes state to /var/firezone, point it at /config
RUN ln -s /config/firezone /var/firezone

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
