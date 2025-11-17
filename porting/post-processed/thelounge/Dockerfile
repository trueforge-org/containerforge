
FROM ghcr.io/trueforge-org/python:3.13.7@sha256:8a2c1da075925eac6d7e3a405035b60a68e1f82cf61b7807a7e87d9ca4f8c999

# set version label
ARG VERSION
ARG TARGETARCH
USER root

# environment settings
ENV THELOUNGE_HOME="/config"

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    build-base \
    git && \
  echo "**** install runtime packages ****" && \
  apk add --no-cache \
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
  apk del --purge \
    build-dependencies && \
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
