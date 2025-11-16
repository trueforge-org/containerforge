
FROM ghcr.io/trueforge-org/ubuntu:24.4

# set version label
ARG VERSION

RUN \
  echo "**** install resilio-sync ****" && \
  if [ -z ${VERSION+x} ]; then \
    VERSION=$(curl -sX GET https://linux-packages.resilio.com/resilio-sync/deb/dists/resilio-sync/non-free/binary-$TARGETARCH/Packages |grep -A 7 -m 1 'Package: resilio-sync' | awk -F ': ' '/Version/{print $2;exit}'); \
  fi && \
  curl -fsSL https://linux-packages.resilio.com/resilio-sync/key.asc | tee /usr/share/keyrings/resilio-sync.asc >/dev/null && \
  echo "deb [$TARGETARCH=$TARGETARCH signed-by=/usr/share/keyrings/resilio-sync.asc] https://linux-packages.resilio.com/resilio-sync/deb resilio-sync non-free" > /etc/apt/sources.list.d/resilio-sync.list && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    "resilio-sync=${VERSION}" && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /var/log/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 8888 55555
VOLUME /config /sync
