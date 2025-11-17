
FROM ghcr.io/trueforge-org/ubuntu:24.4

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    unzip && \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    openjdk17-jre && \
  echo "**** install ubooquity ****" && \
  mkdir -p \
    /app/ubooquity && \
  curl -o \
  /tmp/ubooquity.zip -L \
    "https://vaemendis.net/ubooquity/downloads/Ubooquity-${VERSION}.zip" && \
  unzip /tmp/ubooquity.zip -d /app/ubooquity && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /tmp/*

# copy local files
USER apps
COPY . /
COPY ./root /

# ports and volumes
EXPOSE 2202 2203

VOLUME /config
