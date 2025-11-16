
FROM ghcr.io/linuxserver/baseimage-alpine:3.21

# set version label
ARG VERSION
ARG RSNAPSHOT_VERSION

RUN \
  echo "**** install runtime packages ****" && \
  if [ -z ${RSNAPSHOT_VERSION+x} ]; then \
    RSNAPSHOT_VERSION=$(curl -sL "http://dl-cdn.alpinelinux.org/alpine/v3.21/main/$TARGETARCH/APKINDEX.tar.gz" | tar -xz -C /tmp \
    && awk '/^P:rsnapshot$/,/V:/' /tmp/APKINDEX | sed -n 2p | sed 's/^V://'); \
  fi && \
  apk add --no-cache \
    openssh \
    rsnapshot==${RSNAPSHOT_VERSION} \
    rsync && \
  rm -rf /etc/rsnapshot.conf && \
  ln -s /config/rsnapshot.conf /etc/rsnapshot.conf && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    $HOME/.cache

# copy local files
COPY root/ /

# ports and volumes
VOLUME /config
