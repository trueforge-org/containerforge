
FROM ghcr.io/linuxserver/baseimage-alpine:edge

# set version label
ARG VERSION
ARG BUILD_AGENT_RELEASE

RUN \
  echo "**** install runtime packages ****" && \
  apk add --no-cache --upgrade \
    btrfs-progs \
    docker \
    docker-cli-buildx \
    docker-cli-compose \
    e2fsprogs \
    e2fsprogs-extra \
    git \
    ip6tables \
    iptables \
    openjdk21-jre \
    openssh-client \
    openssh-server-pam \
    openssh-sftp-server \
    xfsprogs \
    xz \
    yq-go && \
  echo "**** setup openssh environment ****" && \
  sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config && \
  usermod --shell /bin/bash abc && \
  rm -rf \
    /tmp/*

# add local files
COPY /root /

EXPOSE 2222

VOLUME /config
