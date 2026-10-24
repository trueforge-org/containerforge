
FROM ghcr.io/trueforge-org/python-node:3.15.1@sha256:47da732d6c20c5d8a7c42844c5eb941257aa1edab5ac657f339703e6dfd5f7d7

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    findutils \
    git \
    nodejs \
    sudo && \
  echo "**** install build packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gyp \
    npm && \
  echo "**** install Pylon ****" && \
  mkdir -p \
    /app/pylon && \
  (curl -fL -o \
  /tmp/pylon.tar.gz \
    "https://github.com/pylonide/pylon/archive/refs/tags/v${VERSION}.tar.gz" || curl -fL -o \
  /tmp/pylon.tar.gz \
    "https://github.com/pylonide/pylon/archive/refs/heads/master.tar.gz") && \
  tar -xzf \
    /tmp/pylon.tar.gz -C \
    /app/pylon/ --strip-components=1 && \
  ln -s \
    /config/sessions \
    /app/pylon/.sessions && \
  echo "**** install node modules ****" && \
  npm install --prefix /app/pylon --ignore-scripts && \
  echo "**** cleanup ****" && \
  apt-get autoremove -y && \
  rm -rf \
    /tmp/*

# add local files
USER apps
COPY --chmod=0755 . /


# ports
EXPOSE 3131

WORKDIR /config
VOLUME /config
