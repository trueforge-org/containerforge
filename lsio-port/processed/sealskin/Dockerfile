
FROM ghcr.io/trueforge-org/ubuntu:24.4

# set version label
ARG VERSION
ENV HOME=/config

# install software
RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --upgrade --virtual=build-dependencies \
    python3-dev \
    py3-pip \
    zip && \
  echo "**** install packages ****" && \
  apk add --no-cache \
    caddy \
    openssl \
    python3 && \
  echo "**** install sealskin ****" && \
  mkdir /opt/sealskin && \
  if [ -z ${VERSION+x} ]; then \
    VERSION=$(curl -sX GET "https://api.github.com/repos/selkies-project/sealskin/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  curl -o \
    /tmp/sealskin.tar.gz -L \
    "https://github.com/selkies-project/sealskin/archive/${VERSION}.tar.gz" && \
  tar xf \
    /tmp/sealskin.tar.gz -C \
    /opt/sealskin --strip-components=1 && \
  pip3 install -r /opt/sealskin/server/requirements.txt --break-system-packages && \
  cd /opt/sealskin/browser_extension && \
  zip -r /sealskin.zip * && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    $HOME/.cache \
    /tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 8000 8443
VOLUME /config /storage
