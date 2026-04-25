
FROM ghcr.io/trueforge-org/ubuntu:24.04@sha256:5fa3c2cf644e1cf005b5ee0feac4b0d0041f65850fb1991bef3926c45a9a371c

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    logrotate \
    netcat-openbsd && \
  echo "**** install openssh-server ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    openssh-client \
    openssh-server \
    openssh-sftp-server && \
  echo "**** setup openssh environment ****" && \
  sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config && \
  usermod --shell /bin/bash apps && \
  rm -rf \
    /tmp/* \
    $HOME/.cache

# add local files
USER apps
COPY --chmod=0755 . /


EXPOSE 2222

VOLUME /config

WORKDIR /config
