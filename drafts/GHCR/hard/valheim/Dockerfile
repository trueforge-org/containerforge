# UNVERIFIED: the published digest of ghcr.io/trueforge-org/steamcmd is not known yet; pin it after apps/steamcmd is built and pushed.
FROM ghcr.io/trueforge-org/steamcmd:20180105-5build1

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    libatomic1 \
    libsdl2-2.0-0 && \
  echo "**** install licence of the wrapper tooling ****" && \
  mkdir -p /usr/share/licenses/valheim && \
  curl -fL -o \
    /usr/share/licenses/valheim/LICENSE \
    "https://raw.githubusercontent.com/community-valheim-tools/valheim-server-docker/v${VERSION}/LICENSE" && \
  echo "**** cleanup ****" && \
  apt-get autoremove -y && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    $HOME/.cache \
    /var/lib/apt/lists/*

# add local files
USER apps
COPY --chmod=0755 . /

# ports and volumes
EXPOSE 2456-2457/udp
VOLUME /config

WORKDIR /config
