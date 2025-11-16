
FROM ghcr.io/trueforge-org/ubuntu:24.4

# set version label
ARG VERSION

RUN \
  echo "**** install packages ****" && \
  if [ -z ${VERSION+x} ]; then \
    VERSION=$(curl -sL "http://dl-cdn.alpinelinux.org/alpine/v3.22/main/$TARGETARCH/APKINDEX.tar.gz" | tar -xz -C /tmp \
    && awk '/^P:smokeping$/,/V:/' /tmp/APKINDEX | sed -n 2p | sed 's/^V://'); \
  fi && \
  apk add --no-cache --virtual=build-dependencies \
    build-base \
    perl-app-cpanminus \
    perl-dev && \
  apk add --no-cache \
    apache2 \
    apache2-ctl \
    apache2-utils \
    apache-mod-fcgid \
    bc \
    bind-tools \
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
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /tmp/* \
    /root/.cpanm \
    /etc/apache2/httpd.conf

# add local files
COPY root/ /

# ports and volumes
EXPOSE 80

VOLUME /config /data
