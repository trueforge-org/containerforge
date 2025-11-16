
FROM ghcr.io/trueforge-org/ubuntu:24.4

# set version label
ARG VERSION

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    unzip && \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    openjdk17-jre && \
  echo "**** install ubooquity ****" && \
  if [ -z ${VERSION+x} ]; then \
    VERSION=$(curl -IsL -w %{url_effective} -o /dev/null https://vaemendis.net/ubooquity/service/download.php \
    | sed 's|.*Ubooquity-\([0-9\.]*\).zip|\1|'); \
  fi && \
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
COPY root/ /

# ports and volumes
EXPOSE 2202 2203

VOLUME /config
