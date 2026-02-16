
FROM ghcr.io/trueforge-org/ubuntu:24.4@sha256:0628c88c702e66783b5565dadf138d0f878ee3c5e8ef8fc7c52b28224ae4d174

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    perl-app-cpanminus \
    perl-dev && \
  apt-get update && apt-get install -y --no-install-recommends \
    apache2 \
    apache2-ctl \
    apache2-utils \
    apache-mod-fcgid \
    bc \
    dnsutils \
    font-noto-cjk \
    irtt \
    openssh-client \
    perl-authen-radius \
    perl-io-socket-inet6 \
    perl-json-maybexs \
    perl-lwp-protocol-https \
    perl-path-tiny \
    smokeping==${VERSION} \
    ssmtp \
    sudo \
    tcptraceroute && \
  echo "**** Build perl TacacsPlus module ****" && \
  cpanm Authen::TacacsPlus && \
  echo "**** Build perl InfluxDB modules ****" && \
  cpanm InfluxDB::HTTP && \
  cpanm Method::Signatures --force && \
  cpanm Object::Result && \
  cpanm InfluxDB::LineProtocol && \
  echo "**** give setuid access to traceroute & tcptraceroute ****" && \
  chmod a+s /usr/bin/traceroute && \
  chmod a+s /usr/bin/tcptraceroute && \
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
