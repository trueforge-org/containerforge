FROM ghcr.io/trueforge-org/node:rolling@sha256:70adf71e6e9d204219ace16d177a96c7b06cc3d881c413eaaa312ed27d13479a

# set version label
ARG VERSION
ARG TARGETARCH
USER root

RUN \
  echo "**** install runtime packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    tftp-hpa && \
  echo "**** install build packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    npm && \
  echo "**** install WebApp ****" && \
  curl -o \
  /tmp/webapp.tar.gz -L \
    "https://github.com/netbootxyz/webapp/archive/${VERSION}.tar.gz" && \
  tar xf \
  /tmp/webapp.tar.gz -C \
    /app/ --strip-components=1 && \
  npm install --prefix /app && \
  echo "**** cleanup ****" && \
  apt-get autoremove -y && \
  rm -rf \
    /tmp/*

# copy local files
USER apps
COPY . /
COPY ./root /

# app runs on port 3000
EXPOSE 3000

VOLUME /config

WORKDIR /config
