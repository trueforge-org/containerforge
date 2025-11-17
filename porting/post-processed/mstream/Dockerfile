## TODO: pin to version tag
FROM ghcr.io/trueforge-org/node:rolling@sha256:56c028d92c9c7e5d29c1265fd0b615c9fbc4995cf5f6ef6007393c3030b4b749

# set version label
ARG VERSION
ARG TARGETARCH
USER root

ENV HOME="/config"

RUN \
  echo "**** install runtime packages ****" && \
  apk add --no-cache --upgrade \
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
  apk del --purge \
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
