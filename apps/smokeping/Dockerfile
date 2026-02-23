
FROM ghcr.io/trueforge-org/ubuntu:24.04@sha256:1c874769d7dc656030d189c30532396d444ab56a283f2828480b4c8a06359ee8

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
  HOME=/tmp cpanm Authen::TacacsPlus || true && \
  echo "**** Build perl InfluxDB modules ****" && \
  HOME=/tmp cpanm InfluxDB::HTTP || true && \
  HOME=/tmp cpanm Method::Signatures --force || true && \
  HOME=/tmp cpanm Object::Result || true && \
  HOME=/tmp cpanm InfluxDB::LineProtocol || true && \
  echo "**** give setuid access to traceroute & tcptraceroute ****" && \
  if [ -f /usr/bin/traceroute ]; then chmod a+s /usr/bin/traceroute; fi && \
  if [ -f /usr/bin/tcptraceroute ]; then chmod a+s /usr/bin/tcptraceroute; fi && \
  echo "**** fix path to cropper.js ****" && \
  sed -i 's#src="/cropper/#/src="cropper/#' /etc/smokeping/basepage.html && \
  echo "**** Cleanup ****" && \
  apt-get autoremove -y && \
  rm -rf \
    /tmp/* \
    /etc/apache2/httpd.conf

# add local files
USER apps
COPY --chmod=0755 . /


# ports and volumes
EXPOSE 80

VOLUME /config
VOLUME /data

WORKDIR /config
