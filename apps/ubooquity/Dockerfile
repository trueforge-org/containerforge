FROM ghcr.io/trueforge-org/java17:17@sha256:9cf9f146b475d249686a6dbe26ac1bff783d0b963bb3d4f63f9a559aa902b5c2

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
  apt-get autoremove -y && \
  rm -rf \
    /tmp/*

# copy local files
USER apps
COPY --chmod=0755 . /


# ports and volumes
EXPOSE 2202 2203

VOLUME /config

WORKDIR /config
