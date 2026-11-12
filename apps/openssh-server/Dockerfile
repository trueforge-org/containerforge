
FROM ghcr.io/trueforge-org/ubuntu:26.04@sha256:f5810a8898e3c4010e9609799c2cc0ef871d42a7637fbdd77f2c62c1e67b495c

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
