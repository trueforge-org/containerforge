
FROM ghcr.io/trueforge-org/ubuntu:24.4

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install runtime packages ****" && \
  apk add --no-cache --upgrade \
    logrotate \
    netcat-openbsd && \
  echo "**** install openssh-server ****" && \
  apk add --no-cache \
    openssh-client==${VERSION} \
    openssh-server-pam==${VERSION} \
    openssh-sftp-server==${VERSION} && \
  echo "**** setup openssh environment ****" && \
  sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config && \
  usermod --shell /bin/bash apps && \
  rm -rf \
    /tmp/* \
    $HOME/.cache

# add local files
USER apps
COPY . /
COPY ./root /

EXPOSE 2222

VOLUME /config
