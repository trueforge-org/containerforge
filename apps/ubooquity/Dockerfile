FROM ghcr.io/trueforge-org/java17:17@sha256:74b81362a2cf4b7f6efb8eb67baf0d1090ce56b38fc9e7a0dc11333b35179e1a

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
