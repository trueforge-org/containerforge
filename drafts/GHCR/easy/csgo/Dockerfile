
# UNVERIFIED: no digest is pinned for the steamcmd base; the plan left it open.
FROM ghcr.io/trueforge-org/steamcmd:20180105-5build1

ARG VERSION
USER root

# UNVERIFIED: this list of 32-bit libs is a candidate set; confirm with ldd on srcds_linux at build time and trim or extend it.
RUN echo "*** Installing 32-bit runtime libraries ***" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    lib32gcc-s1 \
    lib32stdc++6 \
    lib32z1 && \
  mkdir -p /config/serverfiles /config/steamcmd /config/.steam/sdk32 && \
  chown -R apps:apps /config && \
  echo "*** Cleaning Up ***" && \
  rm -rf /var/lib/apt/lists/*

ENV \
  HOME=/config \
  XDG_DATA_HOME=/config \
  GAME_ID=740 \
  GAME_NAME=csgo \
  GAME_PORT=27015 \
  GAME_PARAMS="" \
  VALIDATE=false

USER apps
COPY --chmod=0755 . /

WORKDIR /config

EXPOSE 27015/udp 27015/tcp

VOLUME /config

CMD ["/start.sh"]
