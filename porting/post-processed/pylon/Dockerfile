
FROM ghcr.io/trueforge-org/python:3.13.7@sha256:8a2c1da075925eac6d7e3a405035b60a68e1f82cf61b7807a7e87d9ca4f8c999

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
    findutils \
    git \
    nodejs \
    sudo && \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    build-base \
    npm && \
  echo "**** install Pylon ****" && \
  mkdir -p \
    /app/pylon && \
  curl -o \
  /tmp/pylon.tar.gz -L \
    "https://github.com/pylonide/pylon/archive/v${VERSION}.tar.gz" && \
  tar -xzf \
    /tmp/pylon.tar.gz -C \
    /app/pylon/ --strip-components=1 && \
  ln -s \
    /config/sessions \
    /app/pylon/.sessions && \
  echo "**** install node modules ****" && \
  npm install --prefix /app/pylon && \
  echo "**** cleanup ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /root \
    /tmp/* && \
  mkdir -p \
    /root

# add local files
USER apps
COPY . /


# ports
EXPOSE 3131
