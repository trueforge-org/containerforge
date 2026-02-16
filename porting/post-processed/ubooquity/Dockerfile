FROM ghcr.io/trueforge-org/java17:17

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN echo "**** install ubooquity ****" && \
  mkdir -p \
    /app/ubooquity && \
  curl -o \
  /tmp/ubooquity.zip -L \
    "https://vaemendis.net/ubooquity/downloads/Ubooquity-${VERSION}.zip" && \
  unzip /tmp/ubooquity.zip -d /app/ubooquity && \
  echo "**** cleanup ****" && \
  apt-get del --purge \
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

WORKDIR /config
