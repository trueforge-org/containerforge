
FROM ghcr.io/trueforge-org/ubuntu:24.4

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    openssh \
    rsnapshot==${VERSION} \
    rsync && \
  rm -rf /etc/rsnapshot.conf && \
  ln -s /config/rsnapshot.conf /etc/rsnapshot.conf && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    $HOME/.cache

# copy local files
USER apps
COPY . /
COPY ./root /

# ports and volumes
VOLUME /config
