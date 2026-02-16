
FROM ghcr.io/trueforge-org/ubuntu:24.04

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && \
  apt-get install -y --no-install-recommends \
    fail2ban \
    iptables \
    logrotate \
    msmtp \
    nftables \
    whois && \
  echo "**** copy fail2ban confs to /defaults ****" && \
  mkdir -p \
    /defaults/fail2ban && \
  curl -o \
    /tmp/fail2ban-confs.tar.gz -L \
    "https://github.com/linuxserver/fail2ban-confs/tarball/master" && \
  tar xf \
    /tmp/fail2ban-confs.tar.gz -C \
    /defaults/fail2ban/ --strip-components=1 --exclude=linux*/.editorconfig --exclude=linux*/.gitattributes --exclude=linux*/.github --exclude=linux*/.gitignore --exclude=linux*/LICENSE && \
  echo "**** fix logrotate ****" && \
  sed -i "s#/var/log/messages {}.*# #g" \
    /etc/logrotate.conf && \
  sed -i 's#/usr/sbin/logrotate /etc/logrotate.conf#/usr/sbin/logrotate /etc/logrotate.conf -s /config/log/logrotate.status#g' \
    /etc/periodic/daily/logrotate && \
  rm -rf /etc/fail2ban && \
  ln -s /config/fail2ban /etc/fail2ban && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    $HOME/.cache

# add local files
USER apps
COPY . /
COPY ./root /

# ports and volumes
VOLUME /config

WORKDIR /config
