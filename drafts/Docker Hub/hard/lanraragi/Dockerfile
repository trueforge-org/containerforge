
# Build stage: Perl (CPAN) and frontend (npm) dependencies.
# UNVERIFIED: ubuntu:26.04 base digest is the one used by the repo apps.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS build

ARG VERSION
USER root

# UNVERIFIED: upstream publishes no checksum for the source tarball, so none is verified here.
# UNVERIFIED: cpanm, npm and frontend build commands; upstream builds via cpanfile, local::lib and package.json.
RUN \
  echo "**** install build deps ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    perl \
    cpanminus \
    libffi-dev \
    libarchive-dev \
    libssl-dev \
    nodejs \
    npm \
    curl \
    ca-certificates \
    libvips-dev && \
  echo "**** fetch lanraragi ****" && \
  mkdir -p /build && \
  curl -fsSL -o \
    /tmp/lanraragi.tar.gz \
    "https://github.com/Difegue/LANraragi/archive/refs/tags/v.${VERSION}.tar.gz" && \
  tar xzf \
    /tmp/lanraragi.tar.gz -C \
    /build --strip-components=1 && \
  cd /build && \
  echo "**** perl dependencies ****" && \
  PERL_CPANM_HOME=/tmp/cpanm cpanm --notest --installdeps . -L /build/local && \
  echo "**** frontend dependencies ****" && \
  npm_config_cache=/tmp/npm npm ci --omit=dev && \
  find /build -name '*.map' -delete && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/*

# Runtime stage.
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# UNVERIFIED: runtime package names on ubuntu 26.04 (libvips, libarchive, libffi, poppler).
# UNVERIFIED: valkey is not pinned to a package version here; pin it against the base as apps/valkey does.
RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    tzdata \
    perl \
    libvips42t64 \
    libarchive13t64 \
    libffi8 \
    ghostscript \
    poppler-utils \
    valkey-server \
    valkey-tools && \
  rm -rf /var/lib/apt/lists/*

COPY --from=build /build /app/lanraragi
COPY --from=build /build/LICENSE /usr/share/licenses/lanraragi/LICENSE

RUN \
  echo "**** set ownership ****" && \
  chown -R apps:apps /app

ENV \
  HOME=/config \
  LRR_NETWORK=http://*:3000 \
  MOJO_PROXY=1 \
  MOJO_REVERSE_PROXY=1 \
  PERL5LIB=/app/lanraragi/local/lib/perl5

# copy local files (start.sh)
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 3000
VOLUME /config

WORKDIR /config
