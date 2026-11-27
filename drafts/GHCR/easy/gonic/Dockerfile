FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f01a4295f711d7b14378bedf91fc81b83835ba063493140e22fd08b030ce634a

ARG VERSION
ARG TARGETARCH
USER root

# UNVERIFIED: no upstream checksum is published for the release binaries (plan.md section 10).
# Record the sha256 of each asset and verify it here once it is computed.
# UNVERIFIED: upstream ships ffmpeg for transcoding. It is not installed yet. Add it as a pinned apt package once the version is chosen (plan.md section 4 step 2).

ENV \
  HOME=/config \
  GONIC_LISTEN_ADDR=0.0.0.0:4747 \
  GONIC_DB_PATH=/config/gonic.db \
  GONIC_MUSIC_PATH=/music \
  GONIC_PODCAST_PATH=/config/podcasts \
  GONIC_PLAYLISTS_PATH=/config/playlists \
  GONIC_CACHE_PATH=/config/cache

RUN echo "*** Installing gonic ***" && \
  asset="gonic-linux-${TARGETARCH}-v${VERSION}" && \
  curl -fsSL -o "/tmp/${asset}" \
    "https://github.com/sentriz/gonic/releases/download/v${VERSION}/${asset}" && \
  mkdir -p /app/gonic && \
  install -m 0755 "/tmp/${asset}" /app/gonic/gonic && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  echo "*** Cleaning Up ***" && \
  rm -f "/tmp/${asset}"

USER apps
COPY --chmod=0755 . /

EXPOSE 4747

VOLUME /config
