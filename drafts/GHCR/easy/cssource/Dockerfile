FROM ghcr.io/trueforge-org/steamcmd:20180105-5build1
# UNVERIFIED: no digest pin yet. Add the steamcmd image digest once it is confirmed.

ARG VERSION

USER root

# 32-bit runtime libraries for srcds. UNVERIFIED: keep only the ones ldd shows missing for the server binary.
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      lib32gcc-s1 \
      lib32stdc++6 \
      lib32z1 && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /config/serverfiles /config/steamcmd && \
    chown -R apps:apps /config

ENV \
  HOME=/config \
  XDG_DATA_HOME=/config \
  GAME_PORT=27015 \
  GAME_PARAMS="" \
  VALIDATE=false

USER apps
COPY --chmod=0755 . /

EXPOSE 27015/udp 27015/tcp

VOLUME /config
WORKDIR /config
