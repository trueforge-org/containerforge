FROM ghcr.io/trueforge-org/ubuntu:26.4@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a AS buildstage

# build variables
ARG VERSION
ARG TARGETARCH
ARG DENO_VERSION
USER root

RUN \
  echo "**** install build packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    unzip \
    ca-certificates \
    curl && \
  rm -rf /var/lib/apt/lists/*

# Deno glibc build for the target arch (upstream uses the Alpine image; we need glibc).
# UNVERIFIED: no .sha256sum check yet. Verify the zip against Deno's published checksum in the build.
RUN \
  echo "**** install deno ****" && \
  case "${TARGETARCH}" in \
    amd64) DARCH=x86_64 ;; \
    arm64) DARCH=aarch64 ;; \
    *) echo "unsupported arch: ${TARGETARCH}" >&2; exit 1 ;; \
  esac && \
  curl -fL -o /tmp/deno.zip \
    "https://github.com/denoland/deno/releases/download/v${DENO_VERSION}/deno-${DARCH}-unknown-linux-gnu.zip" && \
  unzip -o /tmp/deno.zip -d /usr/local/bin && \
  chmod 0755 /usr/local/bin/deno && \
  rm -f /tmp/deno.zip

RUN \
  echo "**** fetch source code ****" && \
  mkdir -p /build && \
  curl -fL -o /tmp/profilarr-src.tar.gz \
    "https://github.com/Dictionarry-Hub/profilarr/archive/refs/tags/v${VERSION}.tar.gz" && \
  tar xf /tmp/profilarr-src.tar.gz -C /build --strip-components=1 && \
  rm -f /tmp/profilarr-src.tar.gz

WORKDIR /build

# caches stay in /tmp
ENV DENO_DIR=/tmp/deno-cache \
    DENO_NO_UPDATE_CHECK=1 \
    VITE_CHANNEL=stable

RUN \
  echo "**** install deps ****" && \
  deno ci

# UNVERIFIED: write src/lib/shared/build.ts (version, channel, commit, build time) exactly as
# upstream's Dockerfile heredoc does. Not copied here; read the upstream Dockerfile in the build.

RUN \
  echo "**** build frontend ****" && \
  APP_BASE_PATH=/build/dist/build deno run -A vite build

# UNVERIFIED: upstream's bcrypt warm-up step (deno eval) is not copied yet.

RUN \
  echo "**** compile profilarr ****" && \
  case "${TARGETARCH}" in \
    amd64) DARCH=x86_64 ;; \
    arm64) DARCH=aarch64 ;; \
  esac && \
  deno compile \
    --node-modules-dir=none \
    --exclude-unused-npm \
    --no-check \
    --allow-net \
    --allow-read \
    --allow-write \
    --allow-env \
    --allow-ffi \
    --allow-run \
    --allow-sys \
    --target "${DARCH}-unknown-linux-gnu" \
    --output dist/build/profilarr \
    dist/build/mod.ts && \
  echo "**** assemble /app (read-only at runtime) ****" && \
  mkdir -p /app && \
  cp dist/build/profilarr /app/profilarr && \
  cp -r dist/build/static /app/static && \
  cp dist/build/server.js /app/server.js && \
  mkdir -p /app/deno-cache && \
  cp -r /tmp/deno-cache/plug /app/deno-cache/plug
# UNVERIFIED: the static/, server.js and plug/ paths above follow the upstream runtime COPY list; confirm in the build.

############## runtime stage ##############
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

# set version label
ARG VERSION
USER root

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    git \
    libsqlite3-0 \
    ca-certificates && \
  rm -rf /var/lib/apt/lists/* && \
  mkdir -p /config && \
  chown -R apps:apps /config

# add profilarr (read-only at runtime)
COPY --from=buildstage /app /app
COPY --from=buildstage /build/LICENSE /usr/share/licenses/profilarr/LICENSE

ENV PORT=6868 \
    HOST=0.0.0.0 \
    APP_BASE_PATH=/config \
    TZ=UTC \
    DENO_DIR=/tmp/deno-cache

# add local files
USER apps
COPY --chmod=0755 start.sh /start.sh
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 6868

VOLUME /config
ENTRYPOINT ["/start.sh"]
