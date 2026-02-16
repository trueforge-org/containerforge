
FROM ghcr.io/trueforge-org/python:3.13.7@sha256:436649ee533b748645c1e3ad8e4a1fc3fd2d9d4f0b1cc937bf742a5c3a7f32e5

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# environment settings
ENV THELOUNGE_HOME="/config"

RUN \
  echo "**** install build packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git && \
  echo "**** install runtime packages ****" && \
  apt-get update && apt-get install -y --no-install-recommends \
    yarn && \
  echo "**** download thelounge ****" && \
  mkdir -p \
    /app/thelounge && \
  curl -o \
    /tmp/thelounge.tar.gz -L \
    "https://github.com/thelounge/thelounge/archive/refs/tags/v${VERSION}.tar.gz" && \
  tar xf \
    /tmp/thelounge.tar.gz -C \
    /app/thelounge --strip-components=1 && \
  cd /app/thelounge && \
  echo "**** modify thelounge source ****" && \
  sed -i "s/public: false,/public: true,/g" defaults/config.js && \
  echo "**** install thelounge ****" && \
  yarn install && \
  NODE_ENV=production yarn build && \
  yarn link && \
  yarn --non-interactive cache clean && \
  echo "**** cleanup ****" && \
  apt-get autoremove -y && \
  rm -rf \
    /root \
    /tmp/* && \
  mkdir -p / \
    /root

# copy local files
USER apps
COPY . /


# ports and volumes
EXPOSE 9000
VOLUME /config

WORKDIR /config
