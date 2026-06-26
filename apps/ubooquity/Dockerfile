FROM ghcr.io/trueforge-org/java17:17@sha256:f56b8d1ff78c27ee659ef15f3ae4bb2a5892a5c8fcb7a342688370f13d837569

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
