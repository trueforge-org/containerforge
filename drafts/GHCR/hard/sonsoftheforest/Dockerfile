# UNVERIFIED: no digest pinned; tag is the steamcmd bake VERSION, not confirmed as published
FROM ghcr.io/trueforge-org/steamcmd:20180105-5build1

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** check architecture ****" && \
  test "${TARGETARCH}" = "amd64" || { echo "amd64 only (Wine based)" >&2; exit 1; } && \
  echo "**** install wine and xvfb ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    wine64 \
    xvfb \
    xauth \
    lib32gcc-s1 && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* && \
  rm -rf /var/lib/apt/lists/*

# steamcmd is provided by the base image at /usr/games/steamcmd.
# The game files go to /config; HOME, caches and the Wine prefix go to /tmp.
# NOTE: the base image's /start.sh is a steamcmd wrapper; this app replaces it.
ENV SERVER_DIR=/config/serverfiles

# copy local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
VOLUME /config

WORKDIR /config

ENTRYPOINT ["/start.sh"]
