
FROM ghcr.io/trueforge-org/python:3.13.7@sha256:8a2c1da075925eac6d7e3a405035b60a68e1f82cf61b7807a7e87d9ca4f8c999

# set version label
ARG VERSION
ARG TARGETARCH
USER root
ENV HOME=/config

# install software
RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --upgrade --virtual=build-dependencies \
    zip && \
  echo "**** install packages ****" && \
  apk add --no-cache \
    caddy \
    openssl \
  echo "**** install sealskin ****" && \
  mkdir /opt/sealskin && \
  curl -o \
    /tmp/sealskin.tar.gz -L \
    "https://github.com/selkies-project/sealskin/archive/${VERSION}.tar.gz" && \
  tar xf \
    /tmp/sealskin.tar.gz -C \
    /opt/sealskin --strip-components=1 && \
  pip3 install -r /opt/sealskin/server/requirements.txt --break-system-packages && \
  cd /opt/sealskin/browser_extension && \
  zip -r /sealskin.zip * && \
  chown apps:apps /sealskin.zip && \
  chown apps:apps /storage && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    $HOME/.cache \
    /tmp/*

# add local files
USER apps
COPY . /


# ports and volumes
EXPOSE 8000 8443
VOLUME /config /storage
