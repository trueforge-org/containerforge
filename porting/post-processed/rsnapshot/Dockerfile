
FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:0628c88c702e66783b5565dadf138d0f878ee3c5e8ef8fc7c52b28224ae4d174

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
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

WORKDIR /config
