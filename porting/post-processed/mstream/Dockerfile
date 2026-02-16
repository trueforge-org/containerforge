FROM ghcr.io/trueforge-org/node:22.22.0

# set version label
ARG VERSION
ARG TARGETARCH
USER root

ENV HOME="/config"

RUN \
  echo "**** install runtime packages ****" && \
  apt-get add --no-cache --upgrade \
    openssl && \
  echo "**** install app ****" && \
  mkdir -p \
    /app/mstream && \
  curl -o \
    /tmp/mstream.tar.gz -L \
    "https://github.com/IrosTheBeggar/mStream/archive/v${VERSION}.tar.gz" && \
  tar xzf \
    /tmp/mstream.tar.gz -C \
    /app/mstream/ --strip-components=1 && \
  cd /app/mstream && \
  chown -R apps:apps ./ && \
  su -s /bin/sh apps -c 'HOME=/tmp npm install --omit=dev' && \
  npm link && \
  echo "**** cleanup ****" && \
  rm -rf /app/mstream/save/sync && \
  ln -s /config/sync /app/mstream/save/sync && \
  apt-get del --purge \
    build-dependencies && \
  rm -rf \
    $HOME/.cache \
    $HOME/.npm \
    /tmp/* \
    /tmp/.npm

# add local files
USER apps
COPY . /
COPY ./root /

# ports and volumes
EXPOSE 3000
VOLUME /config

WORKDIR /config
