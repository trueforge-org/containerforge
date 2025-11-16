# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-alpine:3.22

# set version label
ARG BUILD_DATE
ARG VERSION
ARG D2_VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thespad"

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
  S6_VERBOSITY=2

RUN \
  echo "**** install packages ****" && \
  apk add -U --upgrade --no-cache \
    git \
    grep && \
  echo "**** install d2 ****" && \
  mkdir -p /tmp/d2 /output /work && \
  if [ -z ${D2_VERSION+x} ]; then \
    D2_VERSION=$(curl -s https://api.github.com/repos/terrastruct/d2/releases/latest \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  curl -o \
    /tmp/d2.tar.gz -L \
    "https://github.com/terrastruct/d2/releases/download/${D2_VERSION}/d2-${D2_VERSION}-linux-amd64.tar.gz" && \
  tar xzf \
  /tmp/d2.tar.gz -C \
    /tmp/d2 --strip-components=1 && \
  cp /tmp/d2/bin/d2 /usr/local/bin && \
  printf "Version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/*

# copy local files
COPY root/ /

ENTRYPOINT ["/init-d2"]
