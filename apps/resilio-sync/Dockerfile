
FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:63879ad04337bfb36d309809a30de1522a0ac4ab22b117d727c6fef598d41321

# set version label
ARG VERSION
ARG TARGETARCH
USER root

## TODO: pin version
RUN \
  echo "**** install resilio-sync ****" && \
  curl -fsSL https://linux-packages.resilio.com/resilio-sync/key.asc | tee /usr/share/keyrings/resilio-sync.asc >/dev/null && \
  echo "deb [$TARGETARCH=$TARGETARCH signed-by=/usr/share/keyrings/resilio-sync.asc] https://linux-packages.resilio.com/resilio-sync/deb resilio-sync non-free" > /etc/apt/sources.list.d/resilio-sync.list && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    resilio-sync && \
  echo "**** cleanup ****" && \
  chown -R apps:apps /app && chmod -R 755 /app && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /var/log/*

# add local files
USER apps
COPY --chmod=0755 . /
COPY ./root/ /
COPY ./ /

# ports and volumes
EXPOSE 8888 55555
VOLUME /config /sync
