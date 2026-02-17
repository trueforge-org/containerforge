
FROM ghcr.io/trueforge-org/ubuntu:24.04

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cpanminus \
    libperl-dev && \
  apt-get update && apt-get install -y --no-install-recommends \
    apache2 \
    apache2-utils \
    libapache2-mod-fcgid \
    bc \
    dnsutils \
    fonts-noto-cjk \
    irtt \
    openssh-client \
    smokeping \
    ssmtp \
    sudo \
    tcptraceroute && \
  echo "**** Build perl TacacsPlus module ****" && \
  HOME=/root cpanm Authen::TacacsPlus || true && \
  echo "**** Build perl InfluxDB modules ****" && \
  HOME=/root cpanm InfluxDB::HTTP || true && \
  HOME=/root cpanm Method::Signatures --force || true && \
  HOME=/root cpanm Object::Result || true && \
  HOME=/root cpanm InfluxDB::LineProtocol || true && \
  echo "**** give setuid access to traceroute & tcptraceroute ****" && \
  if [ -f /usr/bin/traceroute ]; then chmod a+s /usr/bin/traceroute; fi && \
  if [ -f /usr/bin/tcptraceroute ]; then chmod a+s /usr/bin/tcptraceroute; fi && \
  echo "**** fix path to cropper.js ****" && \
  sed -i 's#src="/cropper/#/src="cropper/#' /etc/smokeping/basepage.html && \
  echo "**** Cleanup ****" && \
  apt-get autoremove -y && \
  rm -rf \
    /tmp/* \
    /root/.cpanm \
    /etc/apache2/httpd.conf

# add local files
USER apps
COPY . /
COPY ./root /

# ports and volumes
EXPOSE 80

VOLUME /config
VOLUME /data

WORKDIR /config
