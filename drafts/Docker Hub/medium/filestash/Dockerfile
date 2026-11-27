# build stage: compile filestash from source (no release tags; pinned by commit)
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS build

ARG VERSION
USER root

ENV GOPATH=/tmp/go \
    GOCACHE=/tmp/gocache

# UNVERIFIED: these are Debian trixie -dev package names; confirm the Ubuntu 26.04 names (t64 suffixes) with apt-cache policy.
RUN \
  echo "**** install build dependencies ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    build-essential \
    pkg-config \
    make \
    libjpeg-dev \
    libtiff-dev \
    libpng-dev \
    libwebp-dev \
    libraw-dev \
    libheif-dev \
    libgif-dev \
    libvips-dev \
    libavcodec-dev \
    libavdevice-dev \
    libavfilter-dev \
    libavformat-dev \
    libswresample-dev \
    libswscale-dev \
    libavutil-dev && \
  echo "**** fetch filestash ****" && \
  mkdir -p /tmp/src && \
  curl -fL -o /tmp/filestash.tar.gz \
    "https://github.com/mickael-kerjean/filestash/archive/${VERSION}.tar.gz" && \
  tar xzf /tmp/filestash.tar.gz -C /tmp/src --strip-components=1 && \
  echo "**** build ****" && \
  cd /tmp/src && \
  make init && \
  make build && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# runtime stage
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# set version label
ARG VERSION
USER root

# Persistent state lives under /config (state/ and config.json); /app stays read-only.
ENV FILESTASH_PATH=/config

# UNVERIFIED: runtime shared libraries. Add the libs that `ldd /app/filestash/filestash` reports as not found (plan section 11).
RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    ffmpeg \
    libbrotli1 \
    poppler-utils && \
  rm -rf /var/lib/apt/lists/*

COPY --from=build /tmp/src/dist/ /app/filestash/
COPY --from=build /tmp/src/LICENSE /usr/share/licenses/filestash/LICENSE
RUN chown -R apps:apps /app/filestash && \
  chmod -R 755 /app/filestash

# copy local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 8334
VOLUME /config

WORKDIR /config
