
FROM ghcr.io/trueforge-org/ubuntu:24.04

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install packages ****" && \
  apt-get add --no-cache \
    ngircd==${VERSION} \
    ngircd-doc==${VERSION} && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/*

# copy local files
USER apps
COPY . /
COPY ./root /

# ports and volumes
EXPOSE 6667

VOLUME /config

WORKDIR /config
